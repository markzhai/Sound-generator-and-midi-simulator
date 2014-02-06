/*
I write this class to make add new channel easy and convinient.
The Channel class reads Noteon and Noteoff from file.
*/
class Channel {
    String filename;
    BufferedReader reader;
    String line;
    ArrayList<Note> notes = new ArrayList<Note>();
    
    int oto;    // timbre

    public Channel(String filename) {
        this.filename = filename;
        reader = createReader(filename);
        while (true) {
            try {
                line = reader.readLine();
            } 
            catch (IOException e) {
                e.printStackTrace();
                line = null;
            }
            if (line == null) {
                break;
            } 
            else {
                String[] pieces = split(line, ",");

                if (pieces[2].startsWith("NoteOn") || pieces[2].startsWith("NoteOff")) {
                    int index = pieces[1].indexOf("=") + 1;
                    int nextIndex = pieces[1].indexOf(":", pieces[1].indexOf("="));
                    int min = Integer.valueOf(pieces[1].substring(index, nextIndex));

                    index = nextIndex + 1;
                    nextIndex = pieces[1].indexOf(":", index);
                    int sec = Integer.valueOf(pieces[1].substring(index, nextIndex));

                    index = nextIndex + 1;
                    int frame = Integer.valueOf(pieces[1].substring(index, pieces[1].length()));

                    float time = min * 60 + sec + ((float)frame) / 30;
                    int pitch, vol;
                    float dur = 0;

                    if (pieces[2].startsWith("NoteOn")) {
                        pitch = Integer.valueOf(pieces[2].substring(pieces[2].indexOf("note: ") + 6, pieces[2].indexOf(" vol")));
                        vol = Integer.valueOf(pieces[2].substring(pieces[2].indexOf("vol: ") + 5, pieces[2].indexOf(" dur")));
                        notes.add(new Note(time, pitch, vol, dur));
                    }
                    else if (pieces[2].startsWith("NoteOff")) {
                        pitch = Integer.valueOf(pieces[2].substring(pieces[2].indexOf("note: ") + 6, pieces[2].length()));
                        for (int i = notes.size() - 1; i > 0; --i) {
                            if (notes.get(i).pitch == pitch) {
                                notes.get(i).dur = time - notes.get(i).time;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
    public Note getNextNote(float time) {
        for (int i = 0; i < notes.size(); ++i) {
            if (notes.get(i).time > time)
                return notes.get(i);
        }
        return null;
    }
}

class Note {
    float time;
    int pitch;
    int vol;
    float dur;
    
    public Note(float time, int pitch, int vol, float dur) {
        this.time = time;
        this.pitch = pitch;
        this.vol = vol;
        this.dur = dur;
    }
    
    public String toString() {
        return ("time: " + time + ", Node: " + pitch + " dur: " + dur);
    }
}
