set masters [get_service_paths master]
set master [lindex $masters 0]
open_service master $master

proc load_program fname {
	global master
	set f [open $fname]
	set re {[a-fA-F0-9]}
	set addr 0
	set i 0
	set v {}
	set b [read $f 1]
	while {![eof $f]} {
		if [regexp $re $b] {
			set v $v$b
			set i [expr $i + 1]
			if {$i == 4} {
				master_write_16 $master $addr 0x$v
				set v {}
				set i 0
				set addr [expr $addr + 2]
			}
		}
		set b [read $f 1]
	}
	close $f
}

proc io_write val { 
	global master
	master_write_16 $master 0x00300010 $val
}

proc io_read {} { 
	global master
	return [master_read_16 $master 0x00400010 1] 
}
