# helpers.tcl --
#
# This file contains helper scripts for all tests, like a mem-leak checker, etc.

package require itcl

if {[llength [info commands memory]] && (
    ![info exists ::tcl::inl_mem_test] || $::tcl::inl_mem_test
  )
} {
  proc getbytes {} {lindex [split [memory info] \n] 3 3}
  proc leaktest {script {iterations 3}} {
      set end [getbytes]
      for {set i 0} {$i < $iterations} {incr i} {
          uplevel 1 $script
          set tmp $end
          set end [getbytes]
      }
      return [expr {$end - $tmp}]
  }
  proc itcl_leaktest {testfile} {
    set leak [leaktest [string map [list @test@ $testfile] {
      interp create i
      load {} Itcl i
      i eval {set ::tcl::inl_mem_test 0}
      i eval [list source @test@]
      interp delete i
    }]]
    if {$leak} {
      puts "LEAKED: $leak bytes"
    }
  }
  itcl_leaktest [info script]
  return -code return
}
