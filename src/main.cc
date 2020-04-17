// -*- mode: c++; c-basic-offset: 2; indent-tabs-mode: nil; -*-
//
// Super simple: on click, turn motor twice.

#include <avr/io.h>
#include <util/delay.h>
#include <stdint.h>

// Port D
#define BUTTON_BIT (1<<5)
#define ENABLE_SENSE (1<<3)

// Port B
#define STEP_BIT  (1<<4)
#define LED_RED   (1<<0)
#define LED_GREEN (1<<1)
#define LED_BLUE  (1<<2)

static constexpr int kFullCycle = 2;  // Each step is two delays for |¯|_|
static constexpr int kMicroSteps = 8;
static constexpr uint16_t kMaxStepSpeed = kMicroSteps * 400 * kFullCycle;

// Keep track of button release before next clicked() event is triggered.
// Also: debounce. (Hard-coded on PORTD, bit BUTTON_BIT)
class Button {
  // Let's make the debouncing fairly large as we might expect a foot switch
  // be connected with unknown specs.
  // But not too long to create an annoying lag.
  static constexpr uint16_t kDebounceWait = 30000;

public:
  Button() { PORTD |= BUTTON_BIT; /* pullup */}

  bool clicked() {
    const bool current_pressed = (PIND & BUTTON_BIT) == 0;  // neg. logic
    if (last_debounce_state_ != current_pressed) debounce_counter_ = 0;
    last_debounce_state_ = current_pressed;
    debounce_counter_++;
    if (debounce_counter_ < kDebounceWait)
      return false;
    const bool before = previous_pressed_;
    previous_pressed_ = current_pressed;
    return (current_pressed && !before);
  }

private:
  bool last_debounce_state_ = false;
  uint16_t debounce_counter_ = 0;
  bool previous_pressed_ = false;
};

// Not doing a trapezoidal acceleration motion profile yet, just starting
// slower, then linearly change delay time.
class MotionProfile {
  static constexpr int kCyclesPerDelay = 5;
  static constexpr int kSlowFactor = 5;
  static constexpr int kAccelerationJumps = 1;

  typedef uint16_t delay_t;

public:
  MotionProfile(uint16_t steps, uint16_t steps_per_second)
    : stage_(Stage::INIT), remaining_steps_(steps) {
    SetStepsPerSecond(steps_per_second);
  }

  // Setting speed is also allowed during the operation to allow adjustments.
  void SetStepsPerSecond(uint16_t steps_per_second) {
    target_speed_delay_ = F_CPU / kCyclesPerDelay / steps_per_second;
    start_ramp_delay_ = kSlowFactor * target_speed_delay_;
    accel_steps_ = (start_ramp_delay_ - target_speed_delay_)
      / kAccelerationJumps;
    switch (stage_) {
    case Stage::INIT: current_delay_ = start_ramp_delay_; break;
    case Stage::MOVING: current_delay_ = target_speed_delay_; break;
    default:
      ;
      // We don't mess with current acceleration phases.
    }
  }

  bool has_more() const { return remaining_steps_ > 0; }
  void delay() {
    switch (stage_) {
    case Stage::INIT:
    case Stage::ACCELERATION:
      current_delay_ -= kAccelerationJumps;
      if (current_delay_ <= target_speed_delay_) {
        current_delay_ = target_speed_delay_;
        stage_ = Stage::MOVING;
      } else {
        stage_ = Stage::ACCELERATION;
      }
      break;

    case Stage::MOVING:
      current_delay_ = target_speed_delay_;
      if (remaining_steps_ <= accel_steps_) {
        stage_ = Stage::DECELERATION;
      }
      break;

    case Stage::DECELERATION:
      current_delay_ += kAccelerationJumps;
      if (current_delay_ > start_ramp_delay_)
        current_delay_ = start_ramp_delay_;
      break;
    }

    for (delay_t i = 0; i < current_delay_; ++i)
      asm("");  // prevent optimizing away
    remaining_steps_--;
  }

private:
  enum class Stage {
    INIT,
    ACCELERATION,
    MOVING,
    DECELERATION
  } stage_;

  uint16_t remaining_steps_;
  uint16_t accel_steps_;       // Steps the (ac-/de)celeration phase takes
  delay_t target_speed_delay_; // Speed for normal movement.
  delay_t start_ramp_delay_;   // Targeted speed at start of ramp.

  delay_t current_delay_;      // current delay, changing on circumstances
};

void send_steps(uint16_t steps) {
  MotionProfile step_gen(kMicroSteps*steps*2, kMaxStepSpeed);

  while (step_gen.has_more()) {
    PORTB ^= STEP_BIT;
    step_gen.delay();
  }
}

int main() {
  DDRB = STEP_BIT | LED_RED | LED_GREEN | LED_BLUE;
  PORTB |= LED_RED | LED_GREEN | LED_BLUE;  // Negative logic.

  Button button;
  for (;;) {
    if (button.clicked()) {
      if (PIND & ENABLE_SENSE) {  // Motor enable still off.
        PORTB &= ~LED_RED;
        _delay_ms(10);
        PORTB |= LED_RED;
      } else {
        PORTB &= ~LED_GREEN;
        send_steps(400);
        PORTB |= LED_GREEN;
      }
    }
  }
}
