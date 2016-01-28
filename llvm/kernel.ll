@.fmt1 = private unnamed_addr constant [13 x i8] c"%d %d %d %p\0A\00"

declare i32 @printf(i8*, ...)

%Term = type <{i32, i32, i8, i16*}>

define zeroext i8 @make_color(i8 %fg, i8 %bg) #0 {
    %res1 = shl i8 %bg, 4
    %res2 = or i8 %res1, %fg
    ret i8 %res2
}

define zeroext i16 @make_vgaentry(i8 %ch, i8 %color) #1 {
    %ch16 = zext i8 %ch to i16
    %color16 = zext i8 %color to i16
    %res1 = shl i16 %color16, 8
    %res2 = or i16 %color16, %ch16
    ret i16 %res2
}

define void @term_initialize(%Term* %term) {
entry:
    %row = getelementptr inbounds %Term, %Term* %term, i32 0, i32 0
    %col = getelementptr inbounds %Term, %Term* %term, i32 0, i32 1
    %color = getelementptr inbounds %Term, %Term* %term, i32 0, i32 2
    %buffer0 = getelementptr inbounds %Term, %Term* %term, i32 0, i32 3
    %x = call zeroext i8 (i8, i8) @make_color(i8 1, i8 5)
    store i32 0, i32* %row, align 4
    store i32 0, i32* %col, align 4
    store i8 %x, i8* %color, align 2
    store i16* inttoptr (i64 753664 to i16*), i16** %buffer0, align 8
    %buffer1 = load i16*, i16** %buffer0, align 8
    %limit.0 = mul i32 80, 25
    %val = call zeroext i16(i8, i8) @make_vgaentry(i8 signext 32, i8 zeroext %x)
    br label %cmploop

loopbody:
    %limit.3 = phi i32 [ %limit.2, %cmploop ]
    %idx.1 = mul i32 %limit.0, 2
    %arrayidx = getelementptr inbounds i16, i16* %buffer1, i32 %idx.1
    store i16 %val, i16* %arrayidx
    br label %cmploop

cmploop:
    %limit.1 = phi i32 [ %limit.0, %entry ], [ %limit.3, %loopbody ]
    %limit.2 = sub i32 %limit.1, 1
    %cmp1 = icmp sge i32 0, %limit.2
    br i1 %cmp1, label %loopbody, label %endloop

endloop:
    ret void
}

define void @kernel_main() {
    %term = alloca %Term
    call void @term_initialize(%Term* %term)
    ret void
}
