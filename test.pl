#!/usr/bin/perl

use strict;

use lib "./blib/lib";
use lib "./blib/arch";

use htk;
use Time::localtime;

my $win32=0;

open IN, "perl --version |";
while (<IN>) {
  if (/win32/i) { $win32=1;last; }
}
close IN;

print "Platform win32=$win32\n";

if ($win32) {
  require Win32::Process;
}

sub doeiets {
	print "args:@_\n";
	my $button=shift;
	my $ctext=shift;
    my $text=$button->getValue;
    
	print "Doet iets! $text\n";
	
	$button->setValue($ctext);
	
	my $dlg=new htk::Dialog("dialog1");
	
	my $ok=new htk::Button("button2","OK","main::ok");
	my $cancel=new htk::Button("button3","Cancel","main::cancel");
	my $hbox1=new htk::HBox("hb1");
	my $hbox2=new htk::HBox("hb2");
	my $label1=new htk::Label("label11","Enter this:");
	my $label2=new htk::Label("label22","Enter this:");
	my $entry1=new htk::Entry("entry2","Fit !");
	my $entry2=new htk::Entry("entry3","JE");
	
	
	$dlg->action($cancel,$ok);
	$hbox1->add($label1,$entry1);
	$hbox2->add($label2,$entry2);
	$dlg->add($hbox1,$hbox2);
	
	$dlg->show;
}

sub update_time {
	my $this=shift;
	print ctime(),"\n";
	my $time=ctime();
	$this->setValue(ctime());
return 1;
}


my $process=undef;
my $ProcessObj;

sub ErrorReport{
	print Win32::FormatMessage( Win32::GetLastError() );
}


sub ok {
    print "OK!\n";

    if ($win32) {
	no strict 'subs';
	
		Win32::Process::Create($process,"c:/utils/mp3rec/mp3DirectCut.exe","mp3DirectCut.exe /r",0,NORMAL_PRIORITY_CLASS,".") 
			  or die ErrorReport();
	
    }
	
}

sub cancel {
	my $exitcode;

	if ($win32) {
	
	   if ($process) {
		$process->Kill($exitcode);
		print "Process killed, exicode=$exitcode\n";
		$process=undef;
	   }
	}
	
}

my $window=new htk::Window("main");
my $app=new htk::App("mainApp");

my $text="text";

my $vbox=new htk::VBox("vbox1");

my $hbox=new htk::HBox("hbox1");


my $button=new htk::Button("button",$text,"main::doeiets","JAJA!");
my $edit1=new htk::Text("text","Hallo allemaal");
my $entry1=new htk::Entry("entry1","Dit is invoer!",0);

my $thetime=new htk::Label("thetime",ctime());
$thetime->addTimer(1000,"main::update_time");

$window->add($vbox);

$hbox->add($button);
$vbox->add($hbox);
$hbox->add($entry1);
$vbox->add($edit1);
$vbox->add($thetime);

$window->show;

print $app,"\n";
print $window,"\n";

$app->Run();

