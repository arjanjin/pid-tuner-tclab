%% Gain margin, phase margin and frequency-domain specs (OL / CL / Polar / Nichols)
% Examples 1-3 of the Gain Margin & Phase Margin summary.
% Requires Control System Toolbox.
clear; clc; close all
s = tf('s');

%% Example 1: open loop, G = 500/((s+2)(s+4)(s+8))
G1 = 500/((s+2)*(s+4)*(s+8));
L1 = G1;

%% Example 2: closed loop, G = 100/((s+2)(s+3)(s+4)), find K for PM = 60 deg
G2 = 100/((s+2)*(s+3)*(s+4));
phiDeg = @(G,w) phaseDeg(G,w);                   % unwrapped phase in degrees
wgc2 = fzero(@(w) phiDeg(G2,w) + 120, [0.5 10]); % phase = -180 + PM
K2   = 1/abs(squeeze(freqresp(G2,wgc2)));        % |K G(j wgc)| = 1
L2   = K2*G2;

%% Example 3: closed loop, G = 100(s+2)/((s+1)(s+4)(s+5)(s+6)), find K for GM = 12 dB
G3 = 100*(s+2)/((s+1)*(s+4)*(s+5)*(s+6));
wpc3 = fzero(@(w) phiDeg(G3,w) + 180, [2 20]);   % phase = -180 (independent of K)
K3   = 10^(-12/20)/abs(squeeze(freqresp(G3,wpc3)));
L3   = K3*G3;

systems = {L1, L2, L3};
names   = {'Example 1', 'Example 2', 'Example 3'};
Kvals   = [1 K2 K3];

%% Open-loop and closed-loop specifications
fprintf('K2 = %.4f, K3 = %.4f\n\n', K2, K3);
for i = 1:3
    L = systems{i};
    T = feedback(L, 1);                  % closed loop  L/(1+L)
    S = feedback(1, L);                  % sensitivity  1/(1+L)

    % --- open loop ---
    am = allmargin(L);
    [GmRatio, PmDeg, Wpc, Wgc] = margin(L); %#ok<ASGLU>
    GmdB = 20*log10(GmRatio);            % margin() returns a ratio, not dB
    Kp   = dcgain(L);
    ess  = 1/(1+Kp);

    % --- closed loop ---
    T0 = dcgain(T);
    [Mr, wr] = getPeakGain(T, 1e-6, [1e-4 100]);   % resonant peak (absolute)
    Wb = bandwidth(T);                          % -3 dB from DC value
    Ms = getPeakGain(S, 1e-6, [1e-4 100]);

    % --- steady-state error: three ways to get the same number ---
    KpdB   = 20*log10(Kp);               % low-frequency plateau of the Bode magnitude (dB)
    ess_dB = 1/(1 + 10^(KpdB/20));       % read the plateau in dB, convert back to Kp
    y      = step(T, 0:0.01:100);        % unit-step response of the closed loop
    ess_y  = 1 - y(end);                 % final value of the response

    fprintf('%s\n', names{i});
    fprintf('  ess: Kp=%.3f (%.2f dB) -> %.4f | 1-T(0) -> %.4f | step final -> %.4f\n', ...
        Kp, KpdB, ess_dB, 1 - T0, ess_y);
    fprintf('  OL: w_gc=%.3f  PM=%.2f deg | w_pc=%.3f  GM=%.2f dB | Kp=%.3f  ess=%.3f\n', ...
        Wgc, PmDeg, Wpc, GmdB, Kp, ess);
    fprintf('  CL: T(0)=%.4f  Mr=%.3f (%.2f dB) at w_r=%.3f | w_b=%.3f | Ms=%.3f\n\n', ...
        T0, Mr, 20*log10(Mr), wr, Wb, Ms);
end

%% Plots: Bode with margins, Polar (Nyquist) and Nichols
for i = 1:3
    L = systems{i};
    figure('Name', names{i}, 'Position', [100 100 1100 330]);
    subplot(1,3,1); margin(L); grid on                % Bode with GM and PM
    subplot(1,3,2); nyquist(L); hold on               % Polar plot (w = -inf..inf)
    th = linspace(0, 2*pi, 200); plot(cos(th), sin(th), 'k--'); axis equal
    xlim([-2 2]); ylim([-2 2]); title('Polar / Nyquist'); grid on
    subplot(1,3,3); nichols(L); ngrid                 % Nichols with M-contours
    title('Nichols'); xlim([-270 0]); ylim([-40 20])
end

%% Frequency-response table for Example 2 (polar points)
w = [1e-3 1 wgc2 3.002 4.611 5.099 10];
Lw = squeeze(freqresp(L2, w));
ph = phaseDeg(L2, w);                            % unwrapped, degrees
fprintf('%8s %9s %9s %8s %9s\n', 'w', 'Re L', 'Im L', '|L| dB', 'phase');
for k = 1:numel(w)
    fprintf('%8.3f %9.3f %9.3f %8.2f %9.1f\n', w(k), real(Lw(k)), imag(Lw(k)), ...
        20*log10(abs(Lw(k))), ph(k));
end

%% Local function
function p = phaseDeg(G, w)
    [~, ph] = bode(G, w);                        % bode() returns continuous (unwrapped) phase
    p = squeeze(ph);
end
