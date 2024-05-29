s.boot;
s.quit;

s.options.numInputBusChannels = 0;

s.waitForBoot{
	~routine.play;
	Synth.new(\friture);
	~pinkNoise2.play;
};

~routine.play;

(
SynthDef(\pad, {
	var snd;
	snd = VarSaw.ar(\freq.kr(440) * (LFNoise2.kr(1 ! 8) * 0.1).midiratio * [1, 0.5, 2, 0.5, 2, 2, 0.5, 1, 0.5]);
	snd = RLPF.ar(snd, LFNoise2.kr(Rand(1, 4) !2).linexp(-1, 2, 100, 6000), 0.1);
	snd = Splay.ar(snd);
	snd = snd * Env.asr(2, 1, 2).ar(Done.freeSelf, \gate.kr(1));
	snd = snd * -30.dbamp;
	Out.ar(\out.kr(0), snd);
}).add;

SynthDef(\fx, {
	arg verbWet = 0.8, verbRoom = 0.8;
	var snd, wet;
	snd = In.ar(\out.kr(0), 2);
	wet = snd + LocalIn.ar(2);
	wet = (wet + PitchShift.ar(wet, 0.35, 2.0)) * -5.dbamp;
	wet = (wet + PitchShift.ar(wet, 0.15, 0.5)) * -5.dbamp;
	wet = LPF.ar(wet, 8000);
	wet = HPF.ar(wet, 100);
	wet = DelayC.ar(wet, 0.3, 0.6);
	wet = FreeVerb.ar(wet, verbWet, verbRoom, damp: 0.8, mul: 0.8);
	LocalOut.ar(wet);
	snd = snd + wet;
	ReplaceOut.ar(\out.kr(0),snd);
}).add;
)

(
SynthDef(\friture, {
	arg amp=2, dist=2, dens=12, dustamp=1, offset=0, noisefreq=2, noisemul=2,
	noiseoffset=0, frq1=400, frq2=3200, rq1=0.5, rq2=0.1, out=0;

	var sig, env;

	sig = {BPF.ar((Dust2.ar(dens, dustamp, offset)*LFNoise1.ar(noisefreq,noisemul,noiseoffset)),rrand(frq1,frq2),q=rrand(rq1,rq2),1/q.sqrt)}!4;
	sig = (sig*dist).tanh*amp;

	//sig = CombC.ar(sig, 1, 0.8, 1.6, 0.6);
	sig = FreeVerb.ar(sig, 0.33, 0.5, 0.8);

	Out.ar(out,sig);

	}).add;
)

y = Synth.new(\friture);
y.free;

y.set(\dens,(18));
y.set(\amp, 1);
y.set(\dist, 4);
y.set(\rq1,0.6);
y.set(\rq2,0.3);
y.set(\frq1,300);
y.set(\frq2,3800);
y.set(\noisefreq,1);
y.set(\noisemul, 2);
y.set(\noiseoffset,(0.7));
y.set(\out,0);


(
~pinkNoise2 = {
	arg freq = 0.25, amp = 0.1; // 1/4 translates into 1 wave every 4 seconds
	var sig, mod;
	mod = SinOsc.kr(freq: freq, phase: 3pi/2, mul: 0.5, add: 1.2);
	sig = PinkNoise.ar(amp);
	sig = sig * mod;
	Out.ar(0, sig);
};
)

w = ~pinkNoise2.play;
w.release(8);
w.free;


(
~routine = {
arg root = 49;
var chords;
var s;
s = Server.default;

chords = 49 + [
	[0, 3, 7, 10],
	[-2, 2, 5, 9],
	[-4, 0, 3, 7],
];

r = Routine {
	var synths;
	s.makeBundle(s.latency, {
		z = Synth.tail(s, \fx);
	});
	loop {
		chords.do { |chord|
			s.makeBundle(s.latency, {
				synths = chord.collect { |note|
					x = Synth(\pad, [freq: note.midicps]);
				};
			});
			9.5.wait;
			s.makeBundle(s.latency, {
				synths.do { |synth|
					synth.set(\gate, 0);
				};
			});
		};
	};
};
}
)

~routine.play;
~routine.release(1);
