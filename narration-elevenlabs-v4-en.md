# Narration Script: PID Tuner in MATLAB with TCLab (English, for ElevenLabs)

## How to use
- Paste one slide block at a time into Text to Speech and select the newest Eleven model (written for v4; the audio tags are the same style as v3).
- `[pause]`, `[thoughtful]`, `[serious]`, `[calm]` are audio tags that shape pacing and tone. If a tag is read aloud, delete it.
- Symbols are spelled out for the voice (e.g. "tau", "theta", "lambda", "omega c"). Numbers use digits, which the model reads reliably.
- Each block is about 30–60 seconds; the full deck runs roughly 25–30 minutes.
- Content follows the slides in `index.html` as of this file's creation.

---

## Slide 1 — Title
[calm] Hello, and welcome to the TCLab experiment on the PID Tuner in MATLAB, for Control Systems. [pause] We cover the principles, the calculations, and how to apply them to the TCLab. Everything is based on a single model: a gain of 0.913, a delay of 15.3 seconds, and a time constant of 172 seconds. [pause] The plot on the cover shows an IMC-PI controller responding to a 20 degree step, with the heater limited between 0 and 100 percent.

## Slide 2 — Roadmap
[calm] The lecture has four parts. [pause] Part one: the model and controller forms. That means the TCLab's FOPDT model, loop transfer functions, ISA versus Parallel form, and two-degree-of-freedom structure. [pause] Part two: the PID Tuner and IMC-PI. Part three: reading the frequency and time responses. Part four: implementation and robustness. [thoughtful] One thing to remember: every number here comes from the same model. The results of pidtune have to be run in real MATLAB, and are not shown as numbers in this deck.

## Slide 3 — The TCLab FOPDT model
[calm] We start with the model. The TCLab is approximated as a first-order system with dead time, or FOPDT. [pause] The gain K is 0.913 degrees Celsius per percent. The time constant tau is 172 seconds, and the delay theta is 15.3 seconds, identified from a PRBS experiment. [pause] The ratio tau over theta is about 11.2, so the process is lag-dominant, but the delay still limits how much gain we can use. [thoughtful] Also note that G of s describes deviation variables around an operating point, not absolute temperature, and the simulations assume zero initial conditions.

## Slide 4 — Open-loop response
[calm] Here is the open-loop response to a 20 percent heater step. [pause] The final value is 0.913 times 20, which is 18.26 degrees. [pause] A common mistake: tau starts counting only after the delay has passed. [serious] So at theta plus tau, which is 187.3 seconds, the temperature is about 11.54 degrees. Reading 172 seconds directly from the start of the experiment would be wrong.

## Slide 5 — From block diagram to the transfer functions the PID Tuner shows
[calm] This slide links the block diagram to the plots in the PID Tuner. [pause] Let L equal G times C, S equal one over one plus L, and T equal L over one plus L, so S plus T always equals one. [pause] Each plot answers a different question. Reference tracking is T: how fast, and how oscillatory. Controller effort is C times S: does the heater hit its limits? Input disturbance is G times S, output disturbance is S, and open-loop is L. [thoughtful] A caution: heater Q2 is not automatically a channel of G of s. If it transfers heat differently from Q1, you need a separate disturbance model.

## Slide 6 — ISA versus Parallel
[calm] A PID controller can be written in two forms: ISA, or standard, with Kc, Ti and Td; and Parallel, with Kp, Ki and Kd. [pause] Kp equals Kc, Ki equals Kc over Ti, and Kd equals Kc times Td. [pause] For example, IMC-PI with lambda equal to theta gives Kc of 6.157 and Ti of 172 seconds. [serious] A frequent error is to put that Ti of 172 into the Ki slot of pid. That makes the integral action thousands of times too strong, which is not a slightly more aggressive tuning. Always check the parameter form.

## Slide 7 — Two degrees of freedom
[calm] The two-degree-of-freedom structure separates the setpoint path from the feedback path. [pause] The parameters b and c live only in Cr, so they do not change the characteristic equation, one plus G Cf equals zero. In other words, they don't affect stability. [pause] TCLabPIDApp uses c equal to zero: the derivative acts on the measurement only, so there is no derivative kick. [thoughtful] Watch the sign convention in MathWorks, where Cy equals minus Cf. And notice how strongly the first command after a step depends on b and c: for IMC-PID with b equal to 1 and c equal to 0 it is about 171 percent, but with b and c both equal to 1 it jumps past 1800 percent.

## Slide 8 — What is the PID Tuner designing?
[calm] The PID Tuner does not pick ZN or IMC from a table. [pause] It uses the SISO model, chooses a crossover frequency from the process dynamics, and targets a phase margin of about 60 degrees. [pause] For example, omega c of 0.03 radians per second gives a GUI response time of 2 over omega c, about 66.7 seconds. [serious] But that number is not a rise time, a settling time, or the exact time to reach the setpoint. Always verify with the actual response.

## Slide 9 — Designing a PI by hand
[calm] Let's design a PI by hand from omega c of 0.03 and a phase margin of 60 degrees. [pause] First, the process phase at this frequency is about minus 105.33 degrees. [pause] So the PI must contribute minus 14.67 degrees, to bring the total phase to minus 120 degrees. [pause] The phase condition gives Ti of about 127 seconds, and the magnitude condition gives Kc of about 5.57. [pause] Substituting back gives a phase margin of exactly 60 degrees, gain margin 10.69 dB, and Ms about 1.535. [thoughtful] Note that a positive-gain PI can only provide phase between minus 90 and 0 degrees. If the required phase is outside that range, change omega c, the phase margin, or the controller type.

## Slide 10 — IMC-PI: from IMC structure to Kc and Ti
[calm] Now IMC-PI. [pause] Start from the IMC structure, C equals Q over one minus G-hat times Q, choosing Q to cancel the process. [pause] Using the approximation e to the minus theta s equals one minus theta s only in the design step, we get Kc equal to tau over K times lambda plus theta, and Ti equal to tau. [pause] Choosing lambda equal to theta gives Kc of 6.157 and Ti of 172 seconds. [pause] The nominal loop then reduces exactly to e to the minus theta s over A s, with A equal to 30.6 seconds. [serious] But this cancellation only holds when Ti equals tau and the model matches the process exactly.

## Slide 11 — IMC-PI: exact margins
[calm] Because the loop is e to the minus theta s over A s, we can compute the margins exactly. [pause] Omega c is one over A, or 0.03268. Phase margin is 90 degrees minus theta over A in radians, which is 61.35 degrees, and gain margin is pi, about 9.94 dB. [pause] The peak Ms is 1.590, at a frequency of about 0.0748. [thoughtful] Don't confuse two bandwidths: omega c, the unity-loop crossover used for tuning, and the minus 3 dB bandwidth of T, about 0.0735. They are not equal.

## Slide 12 — Multiplying the gain by m
[calm] What happens to phase margin if we multiply the gain by m? [pause] The new crossover is m over A, and PM is 90 degrees minus m times theta over A. [pause] From the table: m equal to 1 gives 61.35 degrees, m equal to 2 gives 32.7, m equal to 3 leaves about 4 degrees, and at m equal to pi it reaches zero. [pause] The first critical point is m equal to pi, which equals the gain margin as a ratio. [serious] But this is only for this nominal loop shape, not a general PID criterion. And phase margin at a single point doesn't tell you Ms, so check the peak of the sensitivity over all frequencies.

## Slide 13 — Tuning rules used as baselines
[calm] The document uses several tuning rules as baselines for comparison. [pause] These are IMC-PID with a first-order Padé approximation; SIMC-PI, where Ti is the smaller of tau and four times lambda plus theta, giving 122.4 seconds here; Ziegler-Nichols reaction curve; and Cohen-Coon. [pause] In the table, IMC-PI gives Kc of 6.157 and Ti of 172 seconds, while IMC-PID gives Kc of 8.574 and Td of 7.324 seconds. [thoughtful] Remember, these are starting points for comparison, not final answers.

## Slide 14 — Using the PID Tuner with the TCLab, step by step
[calm] Here is the practical workflow. [pause] Build the model G with tf, set InputDelay to theta, create the IMC baseline with pidstd, then call pidTuner. [pause] First check that the Plant is the TCLab model, not the G equal to 1 that the app opens with by default. [pause] Set Type to PI and Form to Standard so Kc and Ti match the document. Choose Domain equal to Frequency, starting at omega c of about 0.03 and phase margin of about 60 degrees. [thoughtful] Then add the Reference tracking, Controller effort, and Input disturbance plots and read them together. You need the Control System Toolbox, and Simulink Control Design if you tune a Simulink block.

## Slide 15 — Bode
[calm] The Bode plot shows that delay doesn't change magnitude, but it eats more phase as frequency rises. [pause] IMC-PI has a constant minus 20 dB per decade slope, because L is e to the minus theta s over A s. [pause] ZN-PI has higher gain and a shorter Ti, so it crosses 0 dB at nearly twice the frequency. [pause] Remember the numbers: the delay alone removes 26.3 degrees of phase at 0.03 radians per second, and 52.6 degrees at 0.06. As crossover moves up, the remaining phase disappears quickly.

## Slide 16 — Nyquist and sensitivity
[calm] The Nyquist and sensitivity plots show the distance to the critical point, minus 1. [pause] That distance, the magnitude of one plus L, equals one over S, so a lower Ms means more distance. IMC-PI has Ms of 1.59, SIMC-PI 1.62, but ZN-PI is as high as 3.47. [pause] The Ms equal to 2 line is a reference from the source document, not a universal safety guarantee. [serious] Note that the plot shows only the positive-frequency branch, not the full contour needed to count encirclements. Because the loop has an integrator at s equal to zero, a proper Nyquist stability proof needs more work.

## Slide 17 — Frequency results for all seven rules
[calm] This table summarizes the seven rules. [pause] IMC-PI has a phase margin of 61.35, gain margin 9.94, and Ms of 1.59. IMC-PID has a higher phase margin, 68.51, but Ms rises to 1.865 and gain margin drops to 6.77. [pause] ZN and Cohen-Coon give Ms from about 3.5 to 4.6, leaving only 0.22 to 0.29 of distance to the minus 1 point. [thoughtful] The lesson: a higher phase margin does not mean better on every criterion, and high-gain rules are very sensitive to model mismatch.

## Slide 18 — Time responses
[calm] Before comparing time responses, we must agree on definitions. [pause] Rise time is the time from 10 to 90 percent. Overshoot is a percentage of the final value. Settling time uses a 2 percent band that the response stays within afterward. And IAE is the integral of the absolute error. [pause] Comparing three controllers: IMC-PI has 5.08 percent overshoot and a settling time of 96 seconds, while SIMC-PI has 11.14 percent overshoot and 202 seconds. [thoughtful] The analytical PI hits its phase margin target exactly, yet its settling time is twice as long as IMC-PI, so don't choose on phase margin alone.

## Slide 19 — Load disturbance
[calm] Next, load disturbance, which is why SIMC is useful. [pause] The test is an equivalent plus 10 percent disturbance at the same input as Q1, at 100 seconds. It is not a real Q2 experiment. [pause] Y over Du is G times S. The pole at tau s plus one cancels in L and T, but stays in the G S path, which creates a slow tail at 172 seconds. [pause] The integral of the error under load equals d0 over Ki: 279.4 degree-seconds for IMC-PI and 198.8 for SIMC-PI. So SIMC rejects the disturbance better. [thoughtful] In a real experiment, though, you need enough heater bias to be able to reduce power.

## Slide 20 — Heater limited to 0–100 percent
[serious] This slide changes the conclusion. [pause] For a 20 degree step, IMC-PI's immediate command, Kc times delta r, is 123.1 percent, already over the limit at the first sample. [pause] Yet the long-run need is only 21.91 percent heater. The two numbers answer different time scales. [pause] At full power, the fastest response physics allows is a rise time of at least 33.96 seconds, and reaching 20 degrees no sooner than 57.8 seconds, whatever the gain. [thoughtful] That means extra gain won't make the response faster.

## Slide 21 — Comparison under the same constraints
[calm] Now we compare every rule under identical constraints: a 20 degree step, a 1 second sample time, heater from 0 to 100, and back-calculation. [pause] Every high-gain rule gets a rise time of exactly 33.96 seconds, the physical limit, so extra gain buys only overshoot. [pause] ZN and Cohen-Coon overshoot by around 30 percent or more, while IMC-PI overshoots 3.64 percent and has the lowest IAE, 751.66. [thoughtful] Note this is not the 744 reported in the source, which used different simulation conditions.

## Slide 22 — Back-calculation
[calm] Back-calculation reduces integral accumulation, but doesn't always stop it. [pause] The update is I at k plus one equals I at k, plus the error term, plus Ts over Tt times u minus v, where u is the saturated output and v is what the controller wanted. [pause] In the first sample, the error term adds 0.7159, but the anti-windup term subtracts 0.1345, leaving 0.5814 percent. [thoughtful] The integral still grows, just by less. And while the heater is pinned at 100 percent, every rule delivers the same power.

## Slide 23 — Changing only anti-windup
[calm] Let's change only the anti-windup. Take ZN-PI with the same gains, under three actuator models: unlimited, saturated with no anti-windup, and saturated with back-calculation. [pause] The plots change a lot. Without anti-windup, the integral state accumulates up to 150 percent while the heater can't follow. [serious] The key point: always compare tuning methods under the same implementation. If you change gains, saturation, and anti-windup together, you can't tell whether the difference comes from the tuning or the implementation.

## Slide 24 — The discrete controller used by TCLabPIDApp
[calm] The discrete controller in TCLabPIDApp has three parts. [pause] P is Kc times b r minus y. D is computed from the measurement with a filter. And I updates by Forward Euler, with a back-calculation term. [pause] Order matters: use I of k to compute the current command first, then update to I of k plus one. Swap them and you get a different system. [pause] In MATLAB, set IFormula to ForwardEuler and DFormula to BackwardEuler. [thoughtful] And be aware that a one-second sample time may be too slow for a very fast D filter.

## Slide 25 — Simulating the delay exactly with ZOH
[calm] To simulate the 15.3 second delay exactly with a zero-order hold, we don't round it to 15 or 16. [pause] Split theta into m times Ts plus delta, with m equal to 15 and delta equal to 0.3 seconds. The update for y of k plus one then uses both the older and the newer input. [pause] The coefficients are a of about 0.994203, b old of 0.001585, and b new of 0.003708. [pause] In MATLAB, c2d with the zoh method absorbs the fractional delay into the coefficients for you. [thoughtful] A check value for your code: y at index 16 is about 0.3708 degrees.

## Slide 26 — Lambda
[calm] Lambda is the systematic gain knob of IMC-PI. [pause] Kc is inversely proportional to lambda plus theta, and phase margin is 90 degrees minus theta over lambda plus theta, in radians converted to degrees. [pause] From the table, lambda over theta of 0.5 gives Kc of 8.2 and a phase margin of 51.8, but Ms rises to 1.917. At 10, the phase margin is 84.79 and Ms only 1.085, but the response is very slow. [thoughtful] Lambda near theta gives low IAE in the source's test case. That doesn't make it optimal for every setpoint size and operating point.

## Slide 27 — b and N
[calm] The parameters b and N differ in that one doesn't touch stability and the other does. [pause] Lowering b slows the setpoint response, but not through different poles. It comes from the zero and the residue weights in Cr, while the feedback gains stay the same. [pause] By contrast, Tf equals Td over N sits inside Cf, so changing N changes L, the margins, and the characteristic equation. [pause] From the table, N of 3 gives Ms of 2.052, while N of 10 brings it down to 1.865, but the high-frequency gain, Kc times one plus N, rises to 94.31. [thoughtful] That is the limit on how much noise is amplified into the control command.

## Slide 28 — Model mismatch
[calm] We test the same controller against 27 model-mismatch cases, with K, tau, and theta each at 80, 100, and 120 percent of nominal. [pause] The worst case for phase margin is K up 20 percent, tau down 20 percent, and theta up 20 percent. [pause] At lambda equal to theta, the minimum phase margin falls to 40.31 and the maximum Ms is 2.582. With lambda equal to 2 theta, the maximum Ms drops to 1.75, at the cost of speed. [thoughtful] The plus or minus 20 percent range is an assumed set for teaching, not a confidence interval, and checking 27 points is not a proof of robustness.

## Slide 29 — Performance versus robustness in one picture
[calm] This slide puts two metrics in one picture. [pause] The horizontal axis is Ms of the continuous loop, lower meaning more robust. The vertical axis is the IAE of the 20 degree sampled step with saturation, lower meaning better. [pause] IMC-PI sits in the lower-left corner: both robust and lowest IAE in this set. The higher gains of ZN and Cohen-Coon don't improve IAE, because speed is limited by heater power, yet they are much more sensitive to mismatch. [serious] To be clear, this combines metrics at different levels. It is not an optimization target that the PID Tuner guarantees, and the result depends on step size and operating point.

## Slide 30 — MATLAB commands
[calm] This section gives the MATLAB commands for design and checking. [pause] Use pidtuneOptions with PhaseMargin 60 and DesignFocus balanced, then call pidtune with type PI and omega c of 0.03. You get a controller and an info structure. [pause] Then build the transfer functions with feedback: T for tracking, U for controller effort, D for input disturbance, and S for sensitivity. [pause] Use margin to check Gm, Pm, and the crossovers. [thoughtful] Remember that pidTuner opens the interactive app, while pidtune returns values for scripts, and Gm from margin is a ratio that you must convert to decibels yourself.

## Slide 31 — Design workflow and experiment plan
[calm] The workflow has five steps: Model, Baseline, Tune, Analyze, and Validate. [pause] Identify K, tau, theta, units, and operating point; set the IMC-PI baseline in the correct form; tune; analyze tracking, load, effort, and margins; and finally check sampling, saturation, noise, and mismatch. [pause] The experiments come in five sets. A compares IMC-PI with a MATLAB PI on the same model. B changes omega c one value at a time while holding the phase margin. C changes Design Focus. D adds saturation and anti-windup. And E changes the model or operating point. [thoughtful] The key is that each set should change only one thing.

## Slide 32 — Summary
[calm] Let's summarize the TCLab case study. [pause] One: start from IMC-PI as the baseline. Kc is 6.157, Ti is 172 seconds, giving an exact phase margin of 61.35, gain margin of 9.94, and Ms of 1.59. [pause] Two: the PID Tuner is another design method, not a formula picker, so read the achieved values after every tuning. [pause] Three: read several plots from the same loop. A single phase margin isn't enough; look at Ms, effort, and load together. [pause] Four: the 100 percent heater sets the maximum speed, with rise time of at least 34 seconds whatever the gain, so excess gain only buys overshoot. [pause] Five: check the implementation before real use: parameter form, the block's N, the I and D formulas, anti-windup, and mismatch. [thoughtful] Tuning in the app is just one step. A good controller must be verified under the same conditions as real use. [calm] Thank you.
