/*  
 This program is the CSIT5110 Assignment. 
 
 You can click on the 'Play sound' button to listen to the sounds with the currently 
 selected parameters. When you click on 'Play sound' a single 5 second sound is generated.
 The variables 'freq' (the fundamental frequency), 'sound' (the choice of sound being 
 generated) and 'postprocess' (the post-processing being applied) control the frequency,
 the type of sound that is generated and the post-processing that is applied to the sound.
 These three parameters can be changed by the corresponding GUI controls (the 'Sound Controls'). 
 You can click on the 'Stop sound' button to quickly stop the currently playing sound, 
 if you want to. 
 
 The 'Make all sounds and play' button:
 - When you click on the 'Make all sounds and play' button the program generates all of 
 the 10 individual sounds, one after another, and saves the result in 'allsounds.wav' 
 (which is saved in the processing program directory). It also plays the sounds after generation 
 is completed.
 - With the starting code, when you press this button the program makes just one sound 
 and saves it. So you need to improve the program so that all the 10 individual sounds 
 are generated, one after another, and are stored in the 30 seconds array. 
 Generate one example of each individual sound. This is useful for you (and us) to 
 check that your sounds are being generated correctly. You can use an audio editor 
 such as Audacity to check them.
 
 The 'Make all music and play' button: 
 - When you click on the 'Make all music and play' button the program generates a series of 
 musical notes, puts them together to make music in a 30 second array, applies an echo 
 algorithm to the entire 30 seconds, and saves the result in 'allmusic.wav' (which is saved in 
 the processing program directory). After the generation is completed, it plays the generated 
 music once.
 - When the assignment starting code is given to you one musical note is generated and 
 saved. You need to improve the program so that lots of sounds are generated and added to 
 the music at appropriate starting times, to make your selected MIDI song. 
 
 See the assignment instructions and the assignment marking scheme 
 for more exact information and guidelines.
 
 DR
 */

import java.io.*;
import controlP5.*;

int total_sound_generators = 10;  // The total number of individual sounds that can be generated

// Individual sound generation:
//
// ***** The following audio generation functions are given to you *****
// (1) sine    
// (2) square wave (time domain method)
// (3) square wave (additive method)
// (4) sawtooth wave (time domain method)
//
// ***** You must add the following audio generation functions *****
// (5) sawtooth wave (additive method)
// (6) triangle wave (additive method)
// (7) plucking a piano string sound (additive method) 
// (8) bell sound (FM synthesis method)
// (9) white noise (time domain method)
// (10) four sine wave sound (additive method) 

int sound = 1;  // This controls which sound you want to generate in the range 1-10, see list above

// Post-processing of an individual sound:
//
// (1) *no change to sound*
// (2) exponential decay fade out  
//
// ***** You must add the following post processing functions *****
// 
// (3) low pass filter  - if your student id ends in an odd number   
// (4) high pass filter - if your student id ends in an even number
// (5) linear fade in  - if the second from last digit of your student id is odd  
// (6) linear fade out - if the second from last digit of your student id is even
// (7) boost - all students
// (8) tremolo effect - all students

int postprocess = 2;   // which post-processing you want, see list above

// ***** Functions to look at: *****
//
// in generateSound():
//
// - you need to make sure all 10 individual sounds are correctly
//   generated. Remember that 'freq' controls the fundamental frequency.
//   The only exception to this is any FM sound, where the value of freq
//   is fixed for that sound.
//
// in postprocessSound():
//
// - you need to make sure the various postprocessing algorithms
//   (listed above) are working correctly.
//
// in makeSoundSequence():
//
// - all 10 individual sounds are generated and added to the 30 second 
//   output sequence at appropriate times, so each sound can be clearly heard
//
// - do not apply echo to this 10 sound sequence 
//   (because it would make it harder for you/us to check your individual sounds)
//
// - the sound sequence will be saved as a WAV file; please submit it
//
// in makeMusicSequence():
//
// - lots of individual sounds are generated, appropriate post-processing applied,  
//   and the sounds are added to the 30 second music sequence at appropriate starting times, 
//   to make a series of notes (i.e. a music track).
//
// - apply appropriate post-processing to the notes so that they 
//   sound great. 
//
// - after the notes have all been generated and added, apply
//   echo to the final music sequence so it sounds more interesting 
//
// - the music sequence will be saved as a WAV file; please submit it
//
// in applyEcho():
//
// - apply echo to the music sequence. See PDF notes for example code.
//
// in MIDIPitch2freq():
//
// - you have to complete this function so it will convert a 
//   MIDI pitch number (0-127) into the actual frequency, Hz
//
// - this function will be very useful in the makeMusicSequence() function
//
// function setup()
// - this sets up the program. It is executed once. You don't need to change it.
//
// function draw() 
// - is repeatedly executed many times each second. You don't need to change it.

int sampling_rate = 44100; // number of samples used for 1 second of sound (fixed, don't change)

float[] single_sound_sample;  // array for storing the sound samples for a single sound
int single_sound_duration = 5;  // the duration of an individual sound (in seconds)
int total_single_sound_samples = single_sound_duration * sampling_rate;   // the number of samples for a single sound

float[] music_sample;   // array for storing the music sequence samples of several sounds ( = music)
int music_duration = 30;  // the duration of the complete sound sequence (in seconds)
int total_music_samples = music_duration * sampling_rate;   // the number of samples for the complete music sequence

boolean writing_music = false; // flag, to ensure we don't try to do something while the music sequence is being generated
boolean individual_sound_written = false; // flag, used to ensure individual sound is only created once
boolean busy = false; // flag, used to ensure the program do one thing at a time

float amp = 1.0;  // sound amplitude control, with a arbitrary default value
float max_value = 1.0;  // maximum sample value, in the system we use it is 1.0 (don't change)
float min_value = -1.0; // minimum sample value, in the system we use it is -1.0 (don't change)

float freq = 180;   // freqency to use when generating an individual sound, with an arbitrary default value
float min_freq = 20;  // lowest possible frequency
float max_freq = 5000;  // highest possible frequency

//  variables for additive synthesis code
int total_waves = 22;   // default value of how many sine waves get added together, change as appropriate

//  variables for FM synthesis
float fm_freq = 580;   // frequency of the modulator, change as required
float am = 1;    // amplitude of the modulator, change as required

// GUI related variables
ControlP5 cp5;     // Main GUI controls

// variables for display window size 
int window_width = 1024; // pixels
int window_height = 600; // pixels

Slider fSlider;    // Slider to choose the frequency
RadioButton r;     // RadioButton to choose the sounds
RadioButton r2;    // RadioButton to choose the post-process
Textlabel soundLabel;
Textlabel postProcessingLabel;
Textlabel zoomLabel;

int middle0 = window_height / 2 - 60; // The y position of the 0 line of the sound display
int screen_height = 150;       // The distance of the 1 and -1 line from the middle0
int upper_bound = middle0 - screen_height;
int lower_bound = middle0 + screen_height;
int zoom = 1; // zoom level

int gap_plot = 50; // Various spacing control of the GUI elements
int gap_controls = 30;
int normal = 0xFFFFFFFF; // Color stlye of the GUI contorls
int highlighted = 0xFFFF9900;

// Output buffer for the generated single sound and 30 seconds music
Sample single_sound_output_buffer;
Sample music_output_buffer;

//////////////////////////////////////////////////////////////////////////////

// this method is called only at initialization
void setup() {

    // for a single sound
    single_sound_sample = new float[total_single_sound_samples];

    // for the whole music sequence ( = lots of sounds put together)
    music_sample = new float[total_music_samples]; 

    // specify the window size
    size(window_width, window_height);

    // start the Sonia engine
    Sonia.start(this, sampling_rate);

    // Prepare the output buffers
    single_sound_output_buffer = new Sample(total_single_sound_samples, sampling_rate);
    music_output_buffer = new Sample(total_music_samples, sampling_rate);

    println();    
    println(">>>  To try one sound you can click on the GUI controls."); 
    println(">>>  This can be useful as a quick way to explore some of the sounds your program can generate.");      

    cp5 = new ControlP5(this);

    cp5.addTextlabel("label0").setText("CSIT5110 Audio Generator").setPosition(0, 0).setFont(createFont("Arial", 36)).getCaptionLabel().align(ControlP5.CENTER, ControlP5.CENTER);

    cp5.addTextlabel("label1").setText("Frequency").setPosition(29, lower_bound + gap_plot).setFont(createFont("Arial", 14));
    cp5.addTextlabel("label2").setText("Sound").setPosition(55, lower_bound + gap_plot + gap_controls).setFont(createFont("Arial", 14));
    cp5.addTextlabel("label3").setText("Post-process").setPosition(15, lower_bound + gap_plot + 2 * gap_controls).setFont(createFont("Arial", 14));

    soundLabel = cp5.addTextlabel("label4").setText("Time Domain Display of the Sound: Sine (Time domain method)").setPosition(0, upper_bound - 28).setColor(0xffffffff).setFont(createFont("Arial", 20));
    cp5.addTextlabel("label5").setText("1").setPosition(width - 12, upper_bound - 8).setFont(createFont("Arial", 12));
    cp5.addTextlabel("label6").setText("0").setPosition(width - 12, middle0 - 8).setFont(createFont("Arial", 12));
    cp5.addTextlabel("label7").setText("-1").setPosition(width - 16, lower_bound - 8).setFont(createFont("Arial", 12)).getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM);
    postProcessingLabel = cp5.addTextlabel("label8").setText("Exponential Decay").setPosition(510, lower_bound + gap_plot + 2 * gap_controls + 2).setFont(createFont("Arial", 14));
    zoomLabel = cp5.addTextlabel("label9").setText("Zoom: 1x").setPosition(width - 140, lower_bound + 12).setFont(createFont("Arial", 14));

    cp5.addTextlabel("label10").setText("Sound Controls").setPosition(10, lower_bound + 16).setColor(0xffffffff).setFont(createFont("Arial", 20));

    fSlider = cp5.addSlider("")
        .setPosition(110, lower_bound + gap_plot)
            .setSize(500, 20)
                .setRange(min_freq, max_freq)
                    .setColorBackground(normal)
                        .setColorForeground(highlighted)
                            .setColorActive(highlighted);
    fSlider.setValue(freq).setDecimalPrecision(1);
    fSlider.getValueLabel().setFont(createFont("Arial", 14)).align(ControlP5.RIGHT_OUTSIDE, ControlP5.CENTER);

    r = cp5.addRadioButton("radioButton1")
        .setPosition(110, lower_bound + gap_plot + gap_controls)
            .setSize(20, 20)
                .setItemsPerRow(10)
                    .setSpacingColumn(30)
                        .setColorBackground(normal)
                            .setColorForeground(highlighted)
                                .setColorActive(highlighted)
                                    .setNoneSelectedAllowed(false)
                                        .addItem("s1", 1)
                                            .addItem("s2", 2)
                                                .addItem("s3", 3)
                                                    .addItem("s4", 4)
                                                        .addItem("s5", 5)
                                                            .addItem("s6", 6)
                                                                .addItem("s7", 7)
                                                                    .addItem("s8", 8)
                                                                        .addItem("s9", 9)
                                                                            .addItem("s10", 10);

    for (Toggle t:r.getItems()) {
        t.getCaptionLabel().setFont(createFont("Arial", 14, true));
    }

    r.activate(sound - 1);

    r2 = cp5.addRadioButton("radioButton2")
        .setPosition(110, lower_bound + gap_plot + 2 * gap_controls)
            .setSize(20, 20)
                .setItemsPerRow(10)
                    .setSpacingColumn(30)
                        .setColorBackground(normal)
                            .setColorForeground(highlighted)
                                .setColorActive(highlighted)
                                    .setNoneSelectedAllowed(false)
                                        .addItem("p1", 1)
                                            .addItem("p2", 2)
                                                .addItem("p3", 3)
                                                    .addItem("p4", 4)
                                                        .addItem("p5", 5)
                                                            .addItem("p6", 6)
                                                                .addItem("p7", 7)
                                                                    .addItem("p8", 8);

    for (Toggle t:r2.getItems()) {
        t.getCaptionLabel().setFont(createFont("Arial", 14, true));
    }

    r2.activate(postprocess - 1);

    // Create a button and put it near the right-bottom corner
    cp5.addButton(cp5, "playSound", "Play sound", 2)
        .setPosition(110, lower_bound + gap_plot + 3 * gap_controls)
            .setSize(160, 40)
                .setColorBackground(normal)
                    .setColorForeground(highlighted)
                        .setColorActive(highlighted)
                            .addCallback(new CallbackListener() {
                                public void controlEvent(CallbackEvent theEvent) {
                                    if (busy) return;
                                    switch(theEvent.getAction()) {
                                        case(ControlP5.ACTION_PRESSED): 
                                        break;
                                        case(ControlP5.ACTION_RELEASED):
                                        single_sound_output_buffer.stop();

                                        if (!individual_sound_written) {
                                            generateSound(sound, amp, freq);
                                            postprocessSound(postprocess);
                                            single_sound_output_buffer.write(single_sound_sample);
                                        }            

                                        single_sound_output_buffer.play();
                                        busy = true;
                                        break;
                                    }
                                }
                            }
    )
        .getCaptionLabel().setColor(0).setFont(createFont("Arial", 16, true)).align(ControlP5.CENTER, ControlP5.CENTER);

    // Create a button and put it near the right-bottom corner
    cp5.addButton(cp5, "playSound", "Stop sound", 3)
        .setPosition(310, lower_bound + gap_plot + 3 * gap_controls)
            .setSize(160, 40)
                .setColorBackground(normal)
                    .setColorForeground(highlighted)
                        .setColorActive(highlighted)
                            .addCallback(new CallbackListener() {
                                public void controlEvent(CallbackEvent theEvent) {
                                    switch(theEvent.getAction()) {
                                        case(ControlP5.ACTION_PRESSED): 
                                        break;
                                        case(ControlP5.ACTION_RELEASED):
                                        single_sound_output_buffer.stop();
                                        break;
                                    }
                                }
                            }
    )
        .getCaptionLabel().setColor(0).setFont(createFont("Arial", 16, true)).align(ControlP5.CENTER, ControlP5.CENTER);

    // Create a button and put it near the right-bottom corner
    cp5.addButton(cp5, "makesound", "Make all sounds and play", 0)
        .setPosition(width - 300, lower_bound + gap_plot + gap_controls)
            .setSize(280, 40)
                .setColorBackground(normal)
                    .setColorForeground(highlighted)
                        .setColorActive(highlighted)
                            .addCallback(new CallbackListener() {
                                public void controlEvent(CallbackEvent theEvent) {
                                    if (writing_music) return;
                                    if (busy) return;
                                    switch(theEvent.getAction()) {
                                        case(ControlP5.ACTION_PRESSED): 
                                        break;
                                        case(ControlP5.ACTION_RELEASED): 
                                        makeSoundSequence(); 
                                        break;
                                    }
                                }
                            }
    )
        .getCaptionLabel().setColor(0).setFont(createFont("Arial", 16, true)).align(ControlP5.CENTER, ControlP5.CENTER); 

    // Create a button and put it near the right-bottom corner
    cp5.addButton(cp5, "makeMusicSequence", "Make all music and play", 1)
        .setPosition(width - 300, lower_bound + gap_plot + gap_controls * 3)
            .setSize(280, 40)
                .setColorBackground(normal)
                    .setColorForeground(highlighted)
                        .setColorActive(highlighted)
                            .addCallback(new CallbackListener() {
                                public void controlEvent(CallbackEvent theEvent) {
                                    if (writing_music) return;
                                    if (busy) return;
                                    switch(theEvent.getAction()) {
                                        case(ControlP5.ACTION_PRESSED): 
                                        break;
                                        case(ControlP5.ACTION_RELEASED): 
                                        makeMusicSequence(); 
                                        break;
                                    }
                                }
                            }
    )
        .getCaptionLabel().setColor(0).setFont(createFont("Arial", 16, true)).align(ControlP5.CENTER, ControlP5.CENTER);

    // Zoom In
    cp5.addButton(cp5, "zoomIn", "-", 4)
        .setPosition(width - 30, lower_bound + 10)
            .setSize(20, 20)
                .setColorBackground(normal)
                    .setColorForeground(highlighted)
                        .setColorActive(highlighted)
                            .addCallback(new CallbackListener() {
                                public void controlEvent(CallbackEvent theEvent) {
                                    switch(theEvent.getAction()) {
                                        case(ControlP5.ACTION_PRESSED): 
                                        break;
                                        case(ControlP5.ACTION_RELEASED): 
                                        zoom *= 2;
                                        if (zoom > 256) zoom = 256;
                                        zoomLabel.setText("Zoom: " + str(zoom) + "x"); 
                                        break;
                                    }
                                }
                            }
    )
        .getCaptionLabel().setColor(0).setFont(createFont("Arial", 16, true)).align(ControlP5.CENTER, ControlP5.CENTER);

    // Zoom Out
    cp5.addButton(cp5, "zoomOut", "+", 5)
        .setPosition(width - 55, lower_bound + 10)
            .setSize(20, 20)
                .setColorBackground(normal)
                    .setColorForeground(highlighted)
                        .setColorActive(highlighted)
                            .addCallback(new CallbackListener() {
                                public void controlEvent(CallbackEvent theEvent) {
                                    switch(theEvent.getAction()) {
                                        case(ControlP5.ACTION_PRESSED): 
                                        break;
                                        case(ControlP5.ACTION_RELEASED): 
                                        zoom /= 2;
                                        if (zoom < 1) zoom = 1;
                                        zoomLabel.setText("Zoom: " + str(zoom) + "x");
                                        break;
                                    }
                                }
                            }
    )
        .getCaptionLabel().setColor(0).setFont(createFont("Arial", 16, true)).align(ControlP5.CENTER, ControlP5.CENTER);
}

// this method handle the GUI Control inputs
void controlEvent(ControlEvent theEvent) {
    single_sound_output_buffer.stop();

    if (theEvent.isFrom(fSlider)) {
        freq = fSlider.getValue();
        individual_sound_written = false;
    } 
    else if (theEvent.isFrom(r)) {
        sound = int(theEvent.group().value());

        switch(sound) {
        case 1:
            soundLabel.setText("Time Domain Display of the Sound: Sine (Time domain method)");
            break;
        case 2:
            soundLabel.setText("Time Domain Display of the Sound: Square (Time domain method)");
            break;
        case 3:
            soundLabel.setText("Time Domain Display of the Sound: Square (Additive Synthesis)");
            break;
        case 4:
            soundLabel.setText("Time Domain Display of the Sound: Sawtooth (Time domain method)");
            break;
        case 5:
            soundLabel.setText("Time Domain Display of the Sound: Sawtooth (Additive Synthesis)");
            break;
        case 6:
            soundLabel.setText("Time Domain Display of the Sound: Triangle (Additive Synthesis)");
            break;
        case 7:
            soundLabel.setText("Time Domain Display of the Sound: Piano String");
            break;
        case 8:
            soundLabel.setText("Time Domain Display of the Sound: Bell");
            break;
        case 9:
            soundLabel.setText("Time Domain Display of the Sound: White Noise");
            break;
        case 10:
            soundLabel.setText("Time Domain Display of the Sound: 4 Sine");
            break;
        }

        individual_sound_written = false;
    } 
    else if (theEvent.isFrom(r2)) {
        postprocess = int(theEvent.group().value());

        switch(postprocess) {
        case 1:
            postProcessingLabel.setText("No post processing");
            break;
        case 2:
            postProcessingLabel.setText("Exponential Decay");
            break;
        case 3:
            postProcessingLabel.setText("Low-pass Filter");
            break;
        case 4:
            postProcessingLabel.setText("High-pass Filter");
            break;
        case 5:
            postProcessingLabel.setText("Fade In");
            break;
        case 6:
            postProcessingLabel.setText("Fade Out");
            break;
        case 7:
            postProcessingLabel.setText("Boost");
            break;
        case 8:
            postProcessingLabel.setText("Tremolo");
            break;
        }

        individual_sound_written = false;
    }

    if (!writing_music) { // one thing at a time is better
        if (!individual_sound_written) { // Only need to make the sound once
            single_sound_output_buffer.stop();
            generateSound(sound, amp, freq);
            postprocessSound(postprocess);
            single_sound_output_buffer.write(single_sound_sample);
            individual_sound_written = true;
        }
    }
}

// this function will be called repeatedly
void draw() {

    // draw the background graphics, the origin is at the left top
    background(0, 0, 0);

    float line_correction = middle0;
    stroke(100, 100, 100);
    line(0, line_correction, width - 10, line_correction);
    line(0, lower_bound, width - 10, lower_bound);
    line(0, upper_bound, width - 10, upper_bound);  

    noFill();
    stroke(255, 255, 255);
    rect(10, lower_bound + 15, 660, 180);

    stroke(255, 255, 0);

    int sample_to_draw = width * zoom;

    if (music_output_buffer.isPlaying()) {
        int start_position = music_output_buffer.getCurrentFrame();

        if (start_position + sample_to_draw > total_music_samples) {
            start_position = total_music_samples - sample_to_draw -  zoom;
        }

        if (start_position < 0) {
            start_position = 0;
        }

        // Draw the sample data (only the first 'width' samples, because of screen space))
        for (int i = 0; i < sample_to_draw && i < total_music_samples - zoom; i += zoom) {
            float value1 = music_sample[start_position + i];
            if (value1 > 1) value1 = 1;
            if (value1 < -1) value1 = -1;

            float value2 = music_sample[start_position + i + zoom];
            if (value2 > 1) value2 = 1;
            if (value2 < -1) value2 = -1;

            line(i / zoom, middle0 - value1 * screen_height, i / zoom + 1, middle0 - value2 * screen_height);
        }
    } 
    else {
        busy = false;
        int start_position = 0;

        if (single_sound_output_buffer.isPlaying()) {
            start_position = single_sound_output_buffer.getCurrentFrame();
        }

        if (sample_to_draw > total_single_sound_samples) {
            sample_to_draw = total_single_sound_samples;
        }

        if (start_position + sample_to_draw > total_single_sound_samples) {
            start_position = total_single_sound_samples - sample_to_draw - zoom;
        }

        if (start_position < 0) {
            start_position = 0;
        }

        // Draw the sample data (only the first 'width * 2' samples, because of screen space))
        for (int i = 0; i < sample_to_draw && i < total_single_sound_samples - zoom; i += zoom) {
            float value1 = single_sound_sample[start_position + i];
            if (value1 > 1) value1 = 1;
            if (value1 < -1) value1 = -1;

            float value2 = single_sound_sample[start_position + i + zoom];
            if (value2 > 1) value2 = 1;
            if (value2 < -1) value2 = -1;

            line(i / zoom, middle0 - value1 * screen_height, i / zoom + 1, middle0 - value2 * screen_height);
        }
    }
}

void makeSoundSequence() {
    writing_music = true; // So other things don't interrupt the process
    busy = true;

    // Reset audio samples before generating audio
    for (int i = 0; i < total_music_samples; ++i) { 
        music_sample[i] = 0.0;   // Fill the array with silence before we begin
    }

    // save the values before we change them, restore them afterwards
    float before_music_generation_amp = amp;
    float before_music_generation_freq = freq;
    int before_music_generation_sound = sound;
    int before_music_generation_postprocess = postprocess;

    println();
    println(">>>  Please wait, creating best examples of all sounds and saving to WAV file 'allsounds.wav'...");

    amp = 0.6;
    freq = 260;

    for (sound = 1; sound <= total_sound_generators; ++sound) {
        generateSound(sound, amp, freq);   // generate the sound
        postprocessSound(2);  // post-process the sound (2 = exp decay)
        postprocessSound(5);  // post-process the sound (5 = fade in)
        //postprocessSound(6);  // post-process the sound (6 = fade out)
        postprocessSound(7);  // post-process the sound (7 = boost)
        //Possibly, it is appropriate to use 'boost' at several different places.
        addSound((sound - 1) * 2.5);
    }

    // save the sound samples to a WAV file 
    WAVFileWriter fw = new WAVFileWriter("allsounds.wav");
    fw.Save(music_sample, sampling_rate);

    println(">>>  Finished generating and saving sound sequence... ");

    println(">>>  Start playing the generated sound sequence... ");

    music_output_buffer = new Sample("allsounds.wav");
    music_output_buffer.play();

    println(">>>  Finished playing the generated sound sequence... ");

    // Restore values
    amp = before_music_generation_amp;
    freq = before_music_generation_freq;
    sound = before_music_generation_sound;
    postprocess = before_music_generation_postprocess;

    println(">>>  Have to re-generate the single sound again to return it to what it was before... ");
    writing_music = false; // Let other things happen now
    individual_sound_written = false; // force the original sound to be re-created, because it was used during the music process
    generateSound(sound, amp, freq);
    postprocessSound(postprocess);
}

float MIDIPitch2Freq(int MIDI_pitch) {
    float result = 440.0 * pow(2.0, (MIDI_pitch - 69.0) / 12);
    return result;
}

public void makeMusicSequence() {
    int channelCount = 7;
    Channel[] channels = new Channel[channelCount];

    channels[0] = new Channel("PanFlute.txt");    //35 notes
    channels[0].oto = 2;    // Triangle
    channels[1] = new Channel("ElecPiano.txt");    //450 notes
    channels[1].oto = 1;    // Square
    channels[2] = new Channel("TomDrum.txt");    //115 notes
    channels[2].oto = 10;    //Sawtooth
    channels[3] = new Channel("Taiko.txt");    //115 notes
    channels[3].oto = 6;    // Triangle
    channels[4] = new Channel("SynthBass.txt");    //128 notes
    channels[4].oto = 7;    // Piano String
    channels[5] = new Channel("AcoustcBas.txt");    // 131 notes
    channels[5].oto = 6;    // Triangle
    channels[6] = new Channel("Vox.txt");    // 80notes
    channels[6].oto = 8;    // Sawtooth
    
    // Reset audio samples before generating audio
    for (int i = 0; i < total_music_samples; ++i) { 
        music_sample[i] = 0.0;   // Fill the array with silence before we begin
    }

    writing_music = true; // So other things don't interrupt the process
    busy = true;

    // save the values before we change them, restore them afterwards
    float before_music_generation_amp = amp;
    float before_music_generation_freq = freq;
    int before_music_generation_sound = sound;
    int before_music_generation_postprocess = postprocess;

    println();
    println(">>>  Please wait, creating music sequence and saving to WAV file 'allmusic.wav'...");

    // Extract the MIDI pitches from the MIDI file you have chosen.
    // Remember that you should complete and use function MIDIPitch2freq().
    // (Possibly, you may need to make a similar function to handle the time).

    // Generate and add your melody here.
    float startTime = 12;
    for (int i = 0; i < channelCount; ++i) {
        Note note = null;
        do {
            if (note == null)
                note = channels[i].getNextNote(startTime);
            else
                note = channels[i].getNextNote(note.time);
            if (note == null)    // no more notes found
                break;
            freq = MIDIPitch2Freq(note.pitch);
            if (i == 0)
                amp = map(note.vol, 0, 200, 0, 1.0);       // make the first track quieter
            else
                amp = map(note.vol, 0, 128, 0, 1.0);
            generateSound(channels[i].oto, amp, freq, note.dur);  // generate the sound
            if (i == 5) {
                postprocessSound(2, note.dur);    // Exponential decay
                postprocessSound(8, note.dur);    // Tremolo
            }
            postprocessSound(5, note.dur);    // Fade in
            postprocessSound(6, note.dur);    // Fade out
            addSound(note.time - startTime, note.dur);
        }  while (note.time <  startTime + 30);
    }
    // After all the notes have been added at the correct starting times, apply echo

    println(">>>  Applying echo to the music sequence...");

    applyEcho(); // add echo to the entire music sequence

    // use the 'boost' algorithm on music_sample after applying the echo
    float boost_max = 0, boost_min = 0;
    float biggest, boost_multiplier;
    for (int i = 0; i < total_music_samples; i++) {
        if (boost_max < music_sample[i])
            boost_max = music_sample[i];
        if (boost_min > music_sample[i])
            boost_min = music_sample[i];
    }
    boost_min = -1 * boost_min;
    biggest = max(boost_max, boost_min);
    boost_multiplier = max_value / biggest;
    for (int i = 0; i < total_music_samples; i++) {
        music_sample[i] = music_sample[i] * boost_multiplier;
    }

    // save the sound samples to a WAV file 
    WAVFileWriter fw = new WAVFileWriter("allmusic.wav");
    fw.Save(music_sample, sampling_rate);  

    println(">>>  Finished generating and saving music sequence... ");

    println(">>>  Start playing the generated music sequence... ");

    music_output_buffer = new Sample("allmusic.wav");
    music_output_buffer.play();

    println(">>>  Finished playing the genereated music sequence... ");

    // Restore values
    amp = before_music_generation_amp;
    freq = before_music_generation_freq;
    sound = before_music_generation_sound;
    postprocess = before_music_generation_postprocess;

    total_single_sound_samples = single_sound_duration * sampling_rate;

    println(">>>  Have to re-generate the single sound again to return it to what it was before... ");
    writing_music = false; // Let other things happen now
    individual_sound_written = false; // force the original sound to be re-created, because it was used during the music process

    generateSound(sound, amp, freq);
    postprocessSound(postprocess);
}

void addSound(float start_time) { // the input parameter is the start time, in seconds

    boolean time_error = false; // Simple flag used so that we only have to display a warning once

        // In this function we add the individual sound samples 
    // to the complete music sequence samples. 
    // Another way to think about it is that we are adding a 
    // single musical note to the complete music sequence.

    int start_position = int(start_time * float(sampling_rate)); // Work out the starting sample position

    for (int i = 0; i < total_single_sound_samples; ++i) {

        if ((start_position + i) < total_music_samples) { // Check we are not trying to add at an impossible place
            music_sample[start_position + i] += single_sound_sample[i];  // Add this individual sound to the complete sequence
        } 
        else {
            // If we get to this point then it means we are
            // trying to add sound at a point in time 
            // when the music array has already finished i.e. > 30 seconds
            if (!time_error) println("Cannot add sample(s) at that point in time!"); 
            time_error = true; // Show once is enough, no need to show lots of times
        }
    }
    time_error = false;
    println(">>>  Finished adding a single sound to the sequence\n");
}

// I add it to deal with the duration
void addSound(float start_time, float duration) {

    boolean time_error = false; // Simple flag used so that we only have to display a warning once

        int start_position = int(start_time * float(sampling_rate)); // Work out the starting sample position

    for (int i = 0; i < duration * float(sampling_rate); ++i) {

        if ((start_position + i) < total_music_samples) { // Check we are not trying to add at an impossible place
            music_sample[start_position + i] += single_sound_sample[i];  // Add this individual sound to the complete sequence
        } 
        else {
            if (!time_error) println("Cannot add sample(s) at that point in time!"); 
            time_error = true; // Show once is enough, no need to show lots of times
        }
    }
    time_error = false;
    println(">>>  Finished adding a single sound to the sequence\n");
}


void applyEcho() {
    // This function applies an echo effect to the completed music sequence.
    // You can find pseudo-code for this in the PDF file.
    // You only need to handle one delay line for this project.

    // original duration 0.15, multiplier 0.5
    float delay_line_duration = 0.15; // Length of delay line, in seconds

    // Need to declare the multiplier for the delay line
    // (just one delay line needed for this project)
    float delay_line1_multiplier = 0.6;

    // To hear a good example of the echo effect, it helps if you
    // generate a quick sound i.e. a FM sound of 0.1s duration,
    // and make sure the length of the audio sample array is long
    // enough to hear the resulting effect i.e. 5 seconds.

    // Calculate the length of the delay line
    int delay_line1_length = (int)floor(delay_line_duration * sampling_rate);
    float[] delay_line1_sample; // A delay line
    delay_line1_sample= new float[delay_line1_length]; // Correct array length

    for (int i=0; i < delay_line1_length; i++) {
        // Fill the delay line with silence
        delay_line1_sample[i]=0.0f;
    }

    // Output of the delay line (temporary storage)
    float delay_line1_output;

    // Hopefully, no samples are clipped during the echo process
    // but it could happen. If it happens it messes everything up.
    // Let's be helpful and count how many samples are clipped
    // and tell the user how many samples have a problem
    // at the end of the delay line process.
    int clipping_count;

    clipping_count = 0; // Reset count of samples clipped

    // Now go through every sample and apply/process the
    // delay lines (only 1 in this code)
    for (int i = 0; i < total_music_samples - 1; i++) {
        // Extract the appropriate value from each of the delay lines
        // and, later, add it to the original input sound
        if (i >= delay_line1_length) {
            delay_line1_output = delay_line1_sample[i % delay_line1_length];
        } 
        else { // No audio coming out at the start
            delay_line1_output = 0;
        }
        // Add up the output from all delay lines (just one here)
        // to get the actual result. Note that the delay line
        // outputs are added to the original input samples.
        music_sample[i] = music_sample[i] + (float)(delay_line1_output * delay_line1_multiplier);

        // The following code checks for sample clipping.
        // Note - because echo/reverberation is recursive, clipping
        // of even one single sample may affect many samples later.
        // Hence, if any clipping is encountered during the
        // reverberation process then the whole set of audio
        // samples should be dumped and not used.

        if ((music_sample[i] > 1.0) || (music_sample[i] < -1.0)) { // Clipping situation
            clipping_count++; // Count bad samples
        }

        // Now the delay line(s) need to have the current sample
        // entered into them, at the correct place.

        delay_line1_sample[i % delay_line1_length] = music_sample[i];
    } // end of echo for() loop;
    // proceed to run the loop again to evaluate next output sample

    // Check the clipping situation
    if (clipping_count > 0) {
        println(clipping_count + " samples have been clipped...result is not valid!");
    }
}

// This function generates an individual sound 
void generateSound(int sound, float amp, float freq, float duration) {  
    int duration_samples = (int)(sampling_rate * duration);
    float where_in_a_cycle, fraction_of_a_cycle, one_cycle, half_a_cycle;
    float half_height, sample_value, current_time;

    // Reset audio samples before generating audio
    for (int i = 0; i < total_single_sound_samples; ++i) { 
        single_sound_sample[i] = 0.0;   // Fill the array with silence before we begin
    }

    switch(sound) {

        case (1):   // Generate a sine wave using the time domain method
        {
            for (int i = 0; i < duration_samples; ++i) {
                current_time = i / float(sampling_rate);
                single_sound_sample[i] = amp * sin(TWO_PI * freq * current_time);
            }
        }
        break;  

        case(2):   // Generate a square wave -_-_ using the time domain method
        {
            one_cycle = sampling_rate / freq;
            half_a_cycle = one_cycle / 2;
            for (int i = 0; i < duration_samples; ++i) {
                where_in_a_cycle = i % int(one_cycle);
                if (where_in_a_cycle < half_a_cycle) 
                    single_sound_sample[i] = amp * max_value;
                else
                    single_sound_sample[i] = amp * min_value;
            }
        }
        break;  

        case(3):   // Generate a square wave -_-_ using the additive synthesis method
        {
            total_waves = 20;

            for (int i = 0; i < duration_samples; ++i) {
                current_time = i / float(sampling_rate);
                sample_value = 0;
                for (int wave = 1; wave < total_waves * 2; wave += 2) {
                    sample_value += ((1.0 / wave) * sin(wave * TWO_PI * freq * current_time));
                }
                single_sound_sample[i] = amp * sample_value;
            }
        }
        break;  

        case(4):   // Generate a sawtooth wave /|/| using time domain method
        {
            float value;

            one_cycle = sampling_rate / freq;
            for (int i = 0; i < duration_samples; ++i) {
                value = int(i % one_cycle) / one_cycle;
                single_sound_sample[i] = amp * (value * 2.0f - 1.0f);
            }
        }  
        break;  

        case(5):   // Generate a sawtooth wave \|\| using the additive synthesis method 
        {
            /*** complete this function ***/
            int total_waves = 20;
            for (int i = 0; i < duration_samples; ++i) {
                current_time = i / float(sampling_rate);
                sample_value = 0;
                for (int wave = 1; wave < total_waves; ++wave) {
                    sample_value += ((1.0 / wave) * sin(wave * TWO_PI * freq * current_time));
                }
                single_sound_sample[i] = sample_value;
            }
        }
        break;  

        case(6):   // Generate a triangle wave \/\/ using the additive synthesis method (with cos)
        {   
            /*** complete this function ***/
            int total_waves = 20;
            for (int i = 0; i < duration_samples; ++i) {
                current_time = i / float(sampling_rate);
                sample_value = 0;
                for (int wave = 1; wave < total_waves * 2; wave += 2) {
                    sample_value += ((1.0/ (wave * wave)) * cos(wave * TWO_PI * freq * current_time));
                }
                single_sound_sample[i] = sample_value;
            }
        }
        break;  

        case(7):   // Generate a piano string sound (it's not a piano sound!)
        { 
            // Generate the additive sound described in audio_part1.pdf
            // by adding the sine waves at the correct frequency and correct amplitude.
            // The fundamental frequency comes from the variable 'freq'.

            /*** complete this function ***/
            amp = 0.5;
            //amp = 0.47396;  // the original 0.5 would cause some value over 1, so I modify it to 0.47396
            for (int i = 0; i < duration_samples; ++i) {
                current_time = i / float(sampling_rate);
                single_sound_sample[i] = amp * sin(TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.8 * amp * sin(2 * TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.6 * amp * sin(3 * TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.3 * amp * sin(4 * TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.1 * amp * sin(5 * TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.03 * amp * sin(6 * TWO_PI * freq * current_time);
            }
        }
        break;

        case(8):   // Generate a 'bell' sound using FM synthesis
        {
            // The following parameters must be entered
            freq = 100; 
            fm_freq = 280;
            am = 4;
            amp = 1;

            /*** complete this function ***/
            for (int i = 0; i < duration_samples; ++i) {
                current_time = i / float(sampling_rate);
                single_sound_sample[i] = amp * sin(TWO_PI * freq * current_time + am * sin(TWO_PI * fm_freq * current_time));
            }
        }
        break;  

        case(9):   // Generate white noise
        {   
            /*** complete this function ***/
            for (int i = 0; i < duration_samples; ++i) {
                single_sound_sample[i] = random(min_value, max_value);
            }
        }
        break;  

        case(10):   // Generate '4 sine wave' sound
        {
            // Generate the 4 sine waves 
            // by adding the sine waves at the correct frequency and correct amplitude.
            // The fundamental frequency comes from the variable 'freq'.

            /*** complete this function ***/
            amp = 0.5;
            //float max = 1.0;
            for (int i = 0; i < duration_samples; ++i) {
                current_time = i / float(sampling_rate);
                single_sound_sample[i] = amp * sin(TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.4 * amp * sin(2 * TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.85 * amp * sin(3 * TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.7 * amp * sin(4 * TWO_PI * freq * current_time);
                //if (single_sound_sample[i] > max) max = single_sound_sample[i];
            }
            // System.out.println(max);
        }
        break;
    }
    println(">>>  Finished generating sound number " + sound);
}  

// This function generates an individual sound 
void generateSound(int sound, float amp, float freq) {  

    float where_in_a_cycle, fraction_of_a_cycle, one_cycle, half_a_cycle;
    float half_height, sample_value, current_time;

    // Reset audio samples before generating audio
    for (int i = 0; i < total_single_sound_samples; ++i) { 
        single_sound_sample[i] = 0.0;   // Fill the array with silence before we begin
    }

    switch(sound) {

        case (1):   // Generate a sine wave using the time domain method
        {
            for (int i = 0; i < total_single_sound_samples; ++i) {
                current_time = i / float(sampling_rate);
                single_sound_sample[i] = amp * sin(TWO_PI * freq * current_time);
            }
        }
        break;  

        case(2):   // Generate a square wave -_-_ using the time domain method
        {
            one_cycle = sampling_rate / freq;
            half_a_cycle = one_cycle / 2;
            for (int i = 0; i < total_single_sound_samples; ++i) {
                where_in_a_cycle = i % int(one_cycle);
                if (where_in_a_cycle < half_a_cycle) 
                    single_sound_sample[i] = amp * max_value;
                else
                    single_sound_sample[i] = amp * min_value;
            }
        }
        break;  

        case(3):   // Generate a square wave -_-_ using the additive synthesis method
        {
            total_waves = 20;

            for (int i = 0; i < total_single_sound_samples; ++i) {
                current_time = i / float(sampling_rate);
                sample_value = 0;
                for (int wave = 1; wave < total_waves * 2; wave += 2) {
                    sample_value += ((1.0 / wave) * sin(wave * TWO_PI * freq * current_time));
                }
                single_sound_sample[i] = amp * sample_value;
            }
        }
        break;  

        case(4):   // Generate a sawtooth wave /|/| using time domain method
        {
            float value;

            one_cycle = sampling_rate / freq;
            for (int i = 0; i < total_single_sound_samples; ++i) {
                value = int(i % one_cycle) / one_cycle;
                single_sound_sample[i] = amp * (value * 2.0f - 1.0f);
            }
        }  
        break;  

        case(5):   // Generate a sawtooth wave \|\| using the additive synthesis method 
        {
            /*** complete this function ***/
            int total_waves = 20;
            for (int i = 0; i < total_single_sound_samples; ++i) {
                current_time = i / float(sampling_rate);
                sample_value = 0;
                for (int wave = 1; wave < total_waves; ++wave) {
                    sample_value += ((1.0 / wave) * sin(wave * TWO_PI * freq * current_time));
                }
                single_sound_sample[i] = sample_value;
            }
        }
        break;  

        case(6):   // Generate a triangle wave \/\/ using the additive synthesis method (with cos)
        {   
            /*** complete this function ***/
            int total_waves = 20;
            for (int i = 0; i < total_single_sound_samples; ++i) {
                current_time = i / float(sampling_rate);
                sample_value = 0;
                for (int wave = 1; wave < total_waves * 2; wave += 2) {
                    sample_value += ((1.0/ (wave * wave)) * cos(wave * TWO_PI * freq * current_time));
                }
                single_sound_sample[i] = sample_value;
            }
        }
        break;  

        case(7):   // Generate a piano string sound (it's not a piano sound!)
        { 
            // Generate the additive sound described in audio_part1.pdf
            // by adding the sine waves at the correct frequency and correct amplitude.
            // The fundamental frequency comes from the variable 'freq'.

            /*** complete this function ***/
            amp = 0.5;
            //amp = 0.47396;  // the original 0.5 would cause some value over 1, so I modify it to 0.47396
            for (int i = 0; i < total_single_sound_samples; ++i) {
                current_time = i / float(sampling_rate);
                single_sound_sample[i] = amp * sin(TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.8 * amp * sin(2 * TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.6 * amp * sin(3 * TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.3 * amp * sin(4 * TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.1 * amp * sin(5 * TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.03 * amp * sin(6 * TWO_PI * freq * current_time);
            }
        }
        break;

        case(8):   // Generate a 'bell' sound using FM synthesis
        {
            // The following parameters must be entered
            freq = 100; 
            fm_freq = 280;
            am = 4;
            amp = 1;

            /*** complete this function ***/
            for (int i = 0; i < total_single_sound_samples; ++i) {
                current_time = i / float(sampling_rate);
                single_sound_sample[i] = amp * sin(TWO_PI * freq * current_time + am * sin(TWO_PI * fm_freq * current_time));
            }
        }
        break;  

        case(9):   // Generate white noise
        {   
            /*** complete this function ***/
            for (int i = 0; i < total_single_sound_samples; ++i) {
                single_sound_sample[i] = random(min_value, max_value);
            }
        }
        break;  

        case(10):   // Generate '4 sine wave' sound
        {
            // Generate the 4 sine waves 
            // by adding the sine waves at the correct frequency and correct amplitude.
            // The fundamental frequency comes from the variable 'freq'.

            /*** complete this function ***/
            amp = 0.5;
            //float max = 1.0;
            for (int i = 0; i < total_single_sound_samples; ++i) {
                current_time = i / float(sampling_rate);
                single_sound_sample[i] = amp * sin(TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.4 * amp * sin(2 * TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.85 * amp * sin(3 * TWO_PI * freq * current_time);
                single_sound_sample[i] += 0.7 * amp * sin(4 * TWO_PI * freq * current_time);
                //if (single_sound_sample[i] > max) max = single_sound_sample[i];
            }
            // System.out.println(max);
        }
        break;
    }
    println(">>>  Finished generating sound number " + sound);
}  

// This function applies post processing to the currently generated single sound
void postprocessSound(int postprocess) {  

    switch (postprocess) {

        case(1):  // Nothing is done to the sound after it has been generated
        {
        }
        break;  

        case(2):  // Exponential decay
        {
            float time_constant = 0.2;  // decay constant, see PDF notes for explanation
            float current_time;
            float decay_multiplier = 0;

            for (int i = 0; i < total_single_sound_samples; ++i) {
                current_time = i / float(sampling_rate);
                decay_multiplier = (float)(Math.exp(-1 * current_time / time_constant));
                single_sound_sample[i] = single_sound_sample[i] * decay_multiplier;
            }
        }
        break;  

        case(3): // Low pass filter
        {    
            /*** Complete this function if your student id ends in an odd number ***/
            float[] sample2;

            sample2 = new float[total_single_sound_samples];
            sample2[0] = 0;
            for (int i = 1; i < total_single_sound_samples; ++i) {
                sample2[i] = 0.5 * single_sound_sample[i - 1] + 0.5 * single_sound_sample[i];
            }
            for (int i = 1; i < total_single_sound_samples; ++i) {
                sample2[i] = 0.5 * single_sound_sample[i - 1] + 0.5 * single_sound_sample[i];
            }
            arrayCopy(sample2, single_sound_sample, total_single_sound_samples);
        }
        break;

        case(4): // High pass filter
        {    
            /*** Complete this function if your student id ends in an even number ***/
            float[] sample2;

            sample2 = new float[total_single_sound_samples];
            sample2[0] = 0;
            for (int i = 1; i < total_single_sound_samples; ++i) {
                sample2[i] = 0.5 * single_sound_sample[i - 1] - 0.5 * single_sound_sample[i];
            }
            arrayCopy(sample2, single_sound_sample, total_single_sound_samples);
        }
        break;  

        case(5): // Linear fade in
        {
            /*** Complete this function if the second-to-last digit of your student id is an odd number ***/
            float fade_value = 0.5; // The fade-in duration, seconds
            float fade_multiplier;
            int total_samples_to_fade = int(fade_value * sampling_rate);

            if (total_samples_to_fade > total_single_sound_samples)
                total_samples_to_fade = total_single_sound_samples;
            for (int i = 0; i < total_samples_to_fade; ++i) {
                fade_multiplier = float(i) / total_samples_to_fade;
                single_sound_sample[i] = single_sound_sample[i] * fade_multiplier;
            }
        }
        break;  

        case(6): // Linear fade out
        {
            /*** Complete this function if the second-to-last digit of your student id is an even number ***/
            float fade_value = 0.5; // The fade-in duration, seconds
            float fade_multiplier, temp;
            int total_samples_to_fade = int(fade_value * sampling_rate);

            if (total_samples_to_fade > total_single_sound_samples)
                total_samples_to_fade = total_single_sound_samples;

            int start = total_single_sound_samples - total_samples_to_fade;

            for (int i = start; i < total_single_sound_samples; ++i) {
                temp = float(i - start);
                fade_multiplier = 1 - temp / total_samples_to_fade;
                single_sound_sample[i] = single_sound_sample[i] * fade_multiplier;
            }
        }
        break;  

        case(7): // Boost
        {    
            /*** Complete this function ***/
            float boost_max = 0;
            float boost_min = 0;
            float biggest, boost_multiplier;
            for (int i = 0; i < total_single_sound_samples; i++) {
                if (boost_max < single_sound_sample[i])
                    boost_max = single_sound_sample[i];
                if (boost_min > single_sound_sample[i])
                    boost_min = single_sound_sample[i];
            }
            boost_min = -1 * boost_min;
            biggest = max(boost_max, boost_min);
            boost_multiplier = max_value / biggest;
            for (int i = 0; i < total_single_sound_samples; i++) {
                single_sound_sample[i] = single_sound_sample[i] * boost_multiplier;
            }
        }
        break;  

        case(8): // Tremolo
        {
            /*** Complete this function ***/
            float tremoloFrequency = 20;
            float alpha = 0.5;
            float wetness = 1;
            float multiplier;

            /*** complete this function ***/
            for (int i = 0; i < total_single_sound_samples; ++i) {
                multiplier = alpha + alpha * sin(TWO_PI * tremoloFrequency * i / sampling_rate);
                multiplier = (1 - wetness) + (multiplier * wetness);
                single_sound_sample[i] = multiplier * single_sound_sample[i];
            }
        }
        break;
    } // end of switch sequence

    println(">>>  Finished applying post-process number " + postprocess);
}

// This function considers duration of the sample sound
void postprocessSound(int postprocess, float duration) {  
    int duration_sound_samples = (int)(sampling_rate * duration);
    switch (postprocess) {

        case(1):  // Nothing is done to the sound after it has been generated
        {
        }
        break;  

        case(2):  // Exponential decay
        {
            float time_constant = 0.2;  // decay constant, see PDF notes for explanation
            float current_time;
            float decay_multiplier = 0;

            for (int i = 0; i < duration_sound_samples; ++i) {
                current_time = i / float(sampling_rate);
                decay_multiplier = (float)(Math.exp(-1 * current_time / time_constant));
                single_sound_sample[i] = single_sound_sample[i] * decay_multiplier;
            }
        }
        break;  

        case(3): // Low pass filter
        {    
            /*** Complete this function if your student id ends in an odd number ***/
            float[] sample2;
            float current_time;

            sample2 = new float[duration_sound_samples];
            sample2[0] = 0;
            for (int i = 1; i < duration_sound_samples; ++i) {
                sample2[i] = 0.5 * single_sound_sample[i - 1] + 0.5 * single_sound_sample[i];
            }
            single_sound_sample = sample2;
        }
        break;

        case(4): // High pass filter
        {    
            /*** Complete this function if your student id ends in an even number ***/
            float[] sample2;
            float current_time;

            sample2 = new float[duration_sound_samples];
            sample2[0] = 0;
            for (int i = 1; i < duration_sound_samples; ++i) {
                sample2[i] = 0.5 * single_sound_sample[i - 1] - 0.5 * single_sound_sample[i];
            }
            single_sound_sample = sample2;
        }
        break;  

        case(5): // Linear fade in
        {
            /*** Complete this function if the second-to-last digit of your student id is an odd number ***/
            float fade_value = duration / 8; // The fade-in duration, seconds
            float fade_multiplier;
            int total_samples_to_fade = int(fade_value * sampling_rate);

            if (total_samples_to_fade > duration_sound_samples)
                total_samples_to_fade = duration_sound_samples;
            for (int i = 0; i < total_samples_to_fade; ++i) {
                fade_multiplier = float(i) / total_samples_to_fade;
                single_sound_sample[i] = single_sound_sample[i] * fade_multiplier;
            }
        }
        break;  

        case(6): // Linear fade out
        {
            /*** Complete this function if the second-to-last digit of your student id is an even number ***/
            float fade_value = duration / 8; // The fade-in duration, seconds
            float fade_multiplier, temp;
            int total_samples_to_fade = int(fade_value * sampling_rate);

            if (total_samples_to_fade > duration_sound_samples)
                total_samples_to_fade = duration_sound_samples;

            int start = duration_sound_samples - total_samples_to_fade;

            for (int i = start; i < duration_sound_samples; ++i) {
                temp = float(i - start);
                fade_multiplier = 1 - temp / total_samples_to_fade;
                single_sound_sample[i] = single_sound_sample[i] * fade_multiplier;
            }
        }
        break;  

        case(7): // Boost
        {    
            /*** Complete this function ***/
            float boost_max = 0;
            float boost_min = 0;
            float biggest, boost_multiplier;
            for (int i = 0; i < duration_sound_samples; i++) {
                if (boost_max < single_sound_sample[i])
                    boost_max = single_sound_sample[i];
                if (boost_min > single_sound_sample[i])
                    boost_min = single_sound_sample[i];
            }
            boost_min = -1 * boost_min;
            biggest = max(boost_max, boost_min);
            boost_multiplier = max_value / biggest;
            for (int i = 0; i < duration_sound_samples; i++) {
                single_sound_sample[i] = single_sound_sample[i] * boost_multiplier;
            }
        }
        break;  

        case(8): // Tremolo
        {
            /*** Complete this function ***/
            float frequency = 4;
            float alpha = 0.7;
            float multiplier;

            /*** complete this function ***/
            for (int i = 0; i < duration_sound_samples; ++i) {
                //multiplier = 0.5 + (0.5 * sin(TWO_PI * frequency * (i / sampling_rate)));
                //multiplier = (1 - wetness) + (multiplier * wetness);
                multiplier = 1.0 + alpha * sin(TWO_PI * frequency * i / sampling_rate);
                single_sound_sample[i] = multiplier * single_sound_sample[i];
            }
        }
        break;
    } // end of switch sequence

    println(">>>  Finished applying post-process number " + postprocess);
}

// Safely close the sound engine upon browser shutdown.
public void stop() {
    Sonia.stop();
    super.stop();
}

//////////////////////////////////////////////////////////////////////////
/////     Class for writing audio samples to a WAV file
//////////////////////////////////////////////////////////////////////////
/*

 Class WAVFileWriter
 
 Introduction:
 Save sound data to a PCM, mono, 16-bit WAV file.
 The file created is located at the root directory of the software
 
 Basic File Layout:  
 
 |--------------------------|
 |        RIFF Chunk        |
 |                          |
 |       ckID = "RIFF"      |
 |     format = "WAVE"      |
 |    __________________    |
 |   |   Format Chunk   |   |
 |   |   ckID = 'fmt '  |   |
 |   |__________________|   |
 |    __________________    |
 |   | Sound Data Chunk |   |
 |   |   ckID = 'data'  |   |
 |   |__________________|   |
 |                          |
 |--------------------------|  
 
 File Structure: 
 
 Offset  Length  Name    Content / Description
 0   4   chunkID   "RIFF"
 4   4   chunkSize   ths size of the chunk data bytes
 8   4   format    "WAVE"
 
 12  4   fmtChunkID  "fmt "
 16  4   fmtChunkSize  the size of the rest of the Format Chunk 
 20  2   audioFormat   PCM = 1 (i.e. Linear quantization)
 22  2   channel   the number of channel (mono = 1, stereo = 2)
 24  4   samplingRate  sampling rate in Hz (8000, 11000, 22050, 44100, etc.)
 28  4   bytePerSec  the number of bytes per second
 32  2   blockAlign  the number of bytes for a sample including all channels
 34  2   bitPerSample  8, 16, etc.
 
 36  4   dataChunkID   "data"
 40  4   dataSize  the number of bytes in the data
 44  *   data    sound data
 
 
 */

class WAVFileWriter {

    String filename;

    int chunkSize;    // = numOfSample + dataSize + fmrChunkSize + dataChunkSize

        int fmtChunkSize;     // 16 for PCM   
    short audioFormat;    // 1 for PCM
    short channel;    // mono = 1, stereo = 2
    int samplingRate;     // could be 8000, 44100, ...
    int  bytePerSec;    // = samplingRate * channel * bitPerSample / 8
    short blockAlign;     // = channel * bitPerSample / 8
    short bitPerSample;   // 8, 16, etc

    int dataSize;     // number of bytes in the data


    // constructor
    WAVFileWriter(String _filename) {
        filename = _filename;
    }

    // save to WAV file
    void Save(float[] data, int _samplingRate) { 

        samplingRate = _samplingRate;
        channel = 1;
        bitPerSample = 16;
        audioFormat = 1;
        fmtChunkSize = 16;
        blockAlign = (short)(channel * bitPerSample / 8.0);
        bytePerSec = int(samplingRate * channel * bitPerSample / 8.0);
        dataSize = data.length * blockAlign;
        chunkSize = dataSize + 8 + 12 + fmtChunkSize;

        try { 
            DataOutputStream dataoutputstream = new DataOutputStream(new FileOutputStream(filename)); 

            // write "RIFF" chunk
            dataoutputstream.writeBytes("RIFF");    // chunk ID
            dataoutputstream.writeInt(swapInt(chunkSize));  
            dataoutputstream.writeBytes("WAVE");    // format

            // write "format" chunk
            dataoutputstream.writeBytes("fmt ");    // "fmt" chunk ID
            dataoutputstream.writeInt(swapInt(fmtChunkSize));   
            dataoutputstream.writeShort(swapShort(audioFormat));  
            dataoutputstream.writeShort(swapShort(channel));  
            dataoutputstream.writeInt(swapInt(samplingRate));
            dataoutputstream.writeInt(swapInt(bytePerSec));     
            dataoutputstream.writeShort(swapShort(blockAlign));   
            dataoutputstream.writeShort(swapShort(bitPerSample));   

            // write "data" chunk
            dataoutputstream.writeBytes("data");        // "data" chunk ID
            dataoutputstream.writeInt(swapInt(dataSize));   

            // write actual sound data (for 16-bit mono)
            // need to convert the data from float to short
            short sdata = 0;
            for (int i = 0; i<data.length; ++i) {
                if (data[i] >= 0)
                    sdata = (short)(data[i] * 32767);
                else if (data[i] < 0)
                    sdata = (short)(data[i] * 32768);

                dataoutputstream.writeShort(swapShort(sdata));
            }

            dataoutputstream.close();
        } 
        catch(IOException ioexception) { 
            ioexception.printStackTrace();
        }
    } 

    // swap the bytes in the Integer (4 bytes)
    int swapInt(int i) {
        int byte0 = i & 0xff;
        int byte1 = (i >> 8) & 0xff;
        int byte2 = (i >> 16) & 0xff;
        int byte3 = (i >> 24) & 0xff;
        // swap the byte order
        return (byte0 << 24) | (byte1 << 16) | (byte2 << 8) | byte3;
    }

    // swap the bytes in the Short  (2 bytes)
    short swapShort(short i) {
        int byte0 = i & 0xff;
        int byte1 = (i >> 8) & 0xff;

        // swap the byte order
        return (short)((byte0 << 8) | byte1);
    }
}

