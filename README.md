CSIT5110_F2013_Assignment
=========
20146185 ZHAI Yifan	yzhaiaa@ust.hk

The third-from-last digit of my student id is 1, so i choose a movie theme - Rainman - Leaving Wallbrook On the Road by Hans Zimmer.

1. The start time is 0:12:00.

2. I have created 7 tracks for the music sequence, and used different
sound for each track. Since the white noise sounds good, I have not use that sound.
Channel 2, AccoustcBas
Channel 3, PanFlute
Channel 4, Elec Piano
Channel 5, Synth Bass
Channel 7, Vox
Channel 8, Tom Drum
Channel 9, Taiko

3. I calculate the duration as the interval between corresponding NoteOn and NoteOff. Since addSound() and postProcessingSound() all thinks the duration is 5 seconds, I add two new functions with a duration parameter.

4. I use different sounds to play different tracks. 
Note amplitude is calculated by using amp = map(note.vol, 0, 150, 0, 1.0).

5. After applyEcho(), the music sample would exceed maximum which causes clipping, so I use 'boost' algorithm on the whole music_sample[].

/////////////////////////////////////////////////////////////
I add a Channel class which takes a filename parameter for its construtor. It reads NoteOn and NoteOff from the file and generates an ArrayList<Note> to record all the notes.

I add a new addSound function which takes an additional parameter called duration, so that it can exactly simulate the NoteOff.

In the program, you can use
Channel channel = new Channel("PanFlute.txt");
to load a channel from the file.

For the startTime, you can use a method in Channel class like this
Note note = channel.getNextNote(noteTime);

You see that how easy it is in my program to add a channel and specify the start time.

I use the following code to specify the start time
......
float startTime = 12;
for (int i = 0; i < channelCount; ++i) {
......
It is convenient to change it to another value.
/////////////////////////////////////////////////////////////