#![no_std]

enum VgaColor {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGrey = 7,
    DarkGrey = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    LightBrown = 14,
    White = 15,
}

fn make_color(fg: VgaColor, bg: VgaColor) -> u8 {
    (fg as u8) | (bg as u8) << 4
}

fn make_vgaentry(ch: char, col: u8) -> u16 {
    let ch16: u16 = ch as u16;
    let col16: u16 = col as u16;
    ch as u16 | (col as u16) << 8
}

fn strlen(c_string: &str) -> u32 {
    let mut ret: u32 = 0;
    let bytes: &[u8] = c_string.as_bytes();
    bytes.len() as u32
}

struct TermPos {
    row: u32,
    col: u32,
}

struct TermSize {
    ht: u32,
    wd: u32,
}

struct Buffer {
    buffer: *mut u16,
}
 
struct Term {
    pos: TermPos,
    size: TermSize,
    color: u8,
    buffer: Buffer,
}

impl Buffer {
    fn new(ptr: *mut u16) ->Buffer {
        Buffer { buffer: ptr }
    }

    fn add_entry(&self, idx: u32, entry: u16) {
        unsafe {
            *(((self.buffer as u32) + idx) as *mut u16) = entry;
        }
    }
}

impl Clone for Buffer {
    fn clone(&self) -> Buffer {
        Buffer { buffer: self.buffer }
    }
}

impl TermPos {
    fn new() -> TermPos {
        TermPos {
            row: 0,
            col: 0,
        }
    }

    fn row(&self) -> u32 {
        self.row
    }

    fn col(&self) -> u32 {
        self.col
    }

    fn reset(&mut self) -> () {
        self.row = 0;
        self.col = 0;
    }
}

impl Clone for TermPos {
    fn clone(&self) -> TermPos {
        TermPos {row: self.row(), col: self.col()}
    }
}

impl TermSize {
    fn new() -> TermSize {
        TermSize {
            ht: 80,
            wd: 25,
        }
    }

    fn height(&self) -> u32 {
        self.ht
    }

    fn width(&self) -> u32 {
        self.wd
    }
}

impl Iterator for Term {
    type Item = TermPos;

    fn next(&mut self) -> Option<TermPos> {
        let pos: TermPos = self.pos.clone();
        if self.col() < (self.height() * 2) {
            if self.row() < (self.width() * 2) {
                self.pos.row += 1;
            } else {
                self.pos.col += 1;
                self.pos.row = 0;
            }
            Some(pos)
        } else {
            None
        }
    }
}

impl Term {
    fn new() -> Term {
        let mut term: Term = Term {
            pos: TermPos::new(),
            size: TermSize::new(),
            color: make_color(VgaColor::Red, VgaColor::Black),
            buffer: Buffer::new(0xb8000 as *mut u16),
        };
        term
    }

    fn height(&self) -> u32 {
        self.size.ht
    }

    fn width(&self) -> u32 {
        self.size.wd
    }

    fn row(&self) -> u32 {
        self.pos.row
    }
    
    fn col(&self) -> u32 {
        self.pos.col
    }

    fn color(&self) -> u8 {
        self.color
    }

    fn reset_cursor(&mut self) {
        self.pos.reset();
    }

    fn initialize(&mut self) {
        let buff: Buffer = self.buffer.clone();
        let color = self.color;
        for i in 0..(self.width() * self.height()) {
            let idx: u32 = i * 2;
            let entry: u16 = make_vgaentry(' ', color);
            buff.add_entry(idx, entry);
        }
    }

    fn set_color(&mut self, color: u8) -> () {
        self.color = color;
    }

    fn put_entry(&self, ch: char, color: u8, x: u32, y: u32) -> () {
        let idx: u32 = (y + x) * 2;
        let entry: u16 = make_vgaentry(ch, color);
        self.buffer.add_entry(idx, entry);
    }

    fn put_char(&mut self, ch: char) -> () {
        self.put_entry(ch, self.color, self.col(), self.row());
        self.next();
    }

    fn write_string(&mut self, string: &str) -> () {
        for ch in string.as_bytes() {
            self.put_char(*ch as char);
        }
    }
}


#[no_mangle]
pub extern fn kernel_main() -> () {
    let mut term: Term = Term::new();
    term.initialize();
    term.reset_cursor();
    term.write_string("Hello, World!");
}
