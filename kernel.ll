; A simple kernel written in LLVM IR

@.str1 = private unnamed_addr constant [34 x i8] c"A Simple Kernel Written in LLVM IR"

%Term = type <{i32, i32, i8, i16*}>

define i8 @make_color(i8 %fg, i8 %bg) #0 {
    %res1 = shl i8 %bg, 4
    %res2 = or i8 %res1, %fg
    %conv0 = zext i8 %res2 to i32
    ret i8 %res2
}

define i16 @make_vgaentry(i8 %ch, i8 %color) #1 {
    %ch16 = zext i8 %ch to i16
    %color16 = zext i8 %color to i16
    %res1 = shl i16 %color16, 8
    %res2 = or i16 %res1, %ch16
    ret i16 %res2
}

define void @add_entry(i16* %buffer, i32 %idx, i16 %entry) {
    %arrptr = getelementptr inbounds i16, i16* %buffer, i32 %idx
    store i16 %entry, i16* %arrptr, align 2
    ret void
}

define void @term_initialize(%Term* %term) {
entry:
    %row = getelementptr inbounds %Term, %Term* %term, i32 0, i32 0
    %col = getelementptr inbounds %Term, %Term* %term, i32 0, i32 1
    %color = getelementptr inbounds %Term, %Term* %term, i32 0, i32 2
    %buffer0 = getelementptr inbounds %Term, %Term* %term, i32 0, i32 3
    %bgcolor = call i8 (i8, i8) @make_color(i8 4, i8 0)
    store i32 0, i32* %row, align 4
    store i32 0, i32* %col, align 4
    store i8 %bgcolor, i8* %color, align 2
    store i16* inttoptr (i64 753664 to i16*), i16** %buffer0, align 8
    %buffer1 = load i16*, i16** %buffer0, align 8
    %x = alloca i32, align 4
    %y = alloca i32, align 4
    store i32 0, i32* %y
    %limit.0 = mul i32 80, 25
    %val = call i16(i8,i8) @make_vgaentry(i8 32, i8 %bgcolor)
    br label %cmploop.0

cmploop.0:
    %y.0 = load i32, i32* %y
    %cmp.0 = icmp slt i32 %y.0, 80
    br i1 %cmp.0, label %loopbody.0, label %endloop.0

loopbody.0:
    %y.1 = phi i32 [ %y.0, %cmploop.0 ]
    %y.2 = add i32 %y.1, 1
    store i32 %y.2, i32* %y
    store i32 0, i32* %x
    br label %cmploop.1

cmploop.1:
    %x.0 = load i32, i32* %x
    %cmp.1 = icmp slt i32 %x.0, 25
    br i1 %cmp.1, label %loopbody.1, label %cmploop.0

loopbody.1:
    %x.1 = phi i32 [ %x.0, %cmploop.1 ]
    %y.3 = phi i32 [ %y.0, %cmploop.1 ]
    %x.2 = add i32 %x.1, 1
    store i32 %x.2, i32* %x
    %idx.0 = mul i32 %y.3, 25
    %idx.1 = add i32 %idx.0, %x.1
    call void(i16*, i32, i16) @add_entry(i16* %buffer1, i32 %idx.1, i16 %val)
    br label %cmploop.1

endloop.0:
    ret void
}

define void @put_entry(%Term* %term, i8 %ch) {
entry:
    %x0 = getelementptr inbounds %Term, %Term* %term, i32 0, i32 0
    %y0 = getelementptr inbounds %Term, %Term* %term, i32 0, i32 1
    %color0 = getelementptr inbounds %Term, %Term* %term, i32 0, i32 2
    %buffer0 = getelementptr inbounds %Term, %Term* %term, i32 0, i32 3
    %x1 = load i32, i32* %x0
    %y1 = load i32, i32* %y0
    %color1 = load i8, i8* %color0
    %buffer1 = load i16*, i16** %buffer0
    %idx.0 = mul i32 %y1, 80
    %idx.1 = add i32 %y1, %x1
    %ent = call i16(i8, i8) @make_vgaentry(i8 %ch, i8 %color1)
    call void(i16*, i32, i16) @add_entry(i16* %buffer1, i32 %idx.1, i16 %ent)
    %x2 = add i32 %x1, 1
    %cmp0 = icmp eq i32 %x2, 80
    br i1 %cmp0, label %endofline, label %notendofline

endofline:
    store i32 0, i32* %x0
    %y2 = add i32 %y1, 1
    %cmp1 = icmp eq i32 %y2, 25
    br i1 %cmp1, label %endofscreen, label %notendofscreen

endofscreen:
    store i32 0, i32* %y0
    ret void

notendofscreen:
    store i32 %y2, i32* %y0
    ret void

notendofline:
    store i32 %x2, i32* %x0
    ret void
}

define void @writestr(%Term* %term, i8* %str, i32 %len) {
entry:
    %i.0 = alloca i32, align 4
    store i32 0, i32* %i.0
    %i.1 = load i32, i32* %i.0
    br label %cmploop

loopbody:
    %i.3 = phi i32 [ %i.2, %cmploop ]
    %i.4 = add i32 %i.3, 1
    %ch.0 = getelementptr inbounds i8, i8* %str, i32 %i.3
    %ch.1 = load i8, i8* %ch.0
    call void(%Term*, i8) @put_entry(%Term* %term, i8 %ch.1)
    br label %cmploop

cmploop:
    %i.2 = phi i32 [ %i.1, %entry ], [ %i.4, %loopbody ]
    %cmp.0 = icmp slt i32 %i.2, %len
    br i1 %cmp.0, label %loopbody, label %endfunc

endfunc:
    ret void
}

define void @kernel_main() {
    %term = alloca %Term
    call void @term_initialize(%Term* %term)
    %str = getelementptr inbounds [34 x i8], [34 x i8]* @.str1, i32 0, i32 0
    call void @writestr(%Term* %term, i8* %str, i32 34)
    ret void
}
