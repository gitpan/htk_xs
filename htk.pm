package htk;

# log stubs voor de log server om te gebruiken in perl
# Alleen de client functies

use strict;
use vars qw($VERSION);
$VERSION='0.02';

################################################################

use htk_xs;

my %events;

sub callBack {
	no strict 'refs';
	my $function=shift;
	&$function(@{$events{$function}});
}

package htk::Widget;

sub new {
  my $class=shift;
  my $name=shift;
  my $type=shift;
  my $this;

  $this->{"name"}=$name;
  $this->{"type"}=$type;
  
  $this->{"widgets"}=();
  
  bless $this,$class;

$this;
}

sub add {
	my $this=shift;
	
	while (my $widget=shift) {
	
	  push @{$this->{"widgets"}}, $widget;
	  $this->setWidget($widget);
	
	  htk_xs::htk_add_widget($this->getHandle(),$widget->getHandle());
    }
$this;	
}

sub setHandle {
	my $this=shift;
	my $widget=shift;
	
	$this->{"handle"}=$widget;
}

sub getHandle {
	my $this=shift;
return $this->{"handle"};
}

sub setEvent {
	my $this=shift;
	my $eventFunc=shift;
	my $eventType=shift;
	
	$events{$eventFunc}=\@_;
	$this->{"eventFunc"}=$eventFunc;
	$this->{"eventType"}=$eventType;
	
	htk_xs::htk_set_event($this->getHandle(),$this->{"eventFunc"},$this->{"eventType"});
$this;	
}


sub setTimer {
	my $this=shift;
	my $millisecs=shift;
	my $eventFunc=shift;
	
	$events{$eventFunc}=\@_;
	$this->{"eventFunc"}=$eventFunc;
	
	htk_xs::htk_set_timer($millisecs,$this->{"eventFunc"});
$this;	
}


sub addTimer {
	my $this=shift;
	my $millisecs=shift;
	my $eventFunc=shift;
	
	$this->setTimer($millisecs,$eventFunc,$this,@_);
$this;	
}


sub setProp {
	my $this=shift;
	my $prop=shift;
	if (scalar @_==1) {
		$this->{"prop.$prop"}=shift;
    }
    else {
	  $this->{"prop.$prop"}=@_;
    }
}

sub getProp {
	my $this=shift;
	my $prop=shift;
return $this->{"prop.$prop"};
}

sub getWidget {
	my $this=shift;
	my $name=shift;
return $this->{"widget.$name"};
}

sub setWidget {
	my $this=shift;
	my $widget=shift;
	$this->{"widget.".$widget->{"name"}}=$widget;
}

sub show {
  my $this=shift;
  
  htk_xs::htk_widget_show_all($this->getHandle);
}

sub setValue {
	my $self=shift;
	my $value=shift;
	
	$self->setProp("Value",$value);
}

sub getValue {
	my $self=shift;
return $self->getProp("Value");	
}

sub Quit {
	my $self=shift;
	
	htk_xs::htk_quit();
}



################################################################

package htk::App;

use vars qw(@ISA);
@ISA=qw(htk::Widget);

sub new {
  my $class=shift;
  my $name=shift;
  my $this=$class->SUPER::new($name,"htk::App");

$this;
}

sub DESTROY {
}

sub Run {
  my $this=shift;
  htk_xs::htk_main();
}


################################################################

package htk::Window;

use vars qw(@ISA);
@ISA=qw(htk::Widget);

sub new {
    my $class=shift;
    my $name=shift;
	my $windowtype=shift;
	my $this=$class->SUPER::new($name,"htk::Window");
	
	$this->{"windowtype"}=$windowtype;

	if (not $windowtype) {
		$windowtype=htk_xs::htk_window_toplevel();
	}

	$this->setHandle(htk_xs::htk_window_new($windowtype));

$this;	
}

################################################################

package htk::Dialog;

use vars qw(@ISA);
@ISA=qw(htk::Widget);

sub new {
	my $class=shift;
	my $name=shift;
	my $this=$class->SUPER::new($name,"htk::Dialog");
	
	$this->setHandle(htk_xs::htk_dialog_new());
	
$this;	
}

sub add {
	my $this=shift;
	
	while(my $widget=shift) {
	  push @{$this->{"widgets"}}, $widget;
	  $this->setWidget($widget);
	
	  htk_xs::htk_dialog_add($this->getHandle(),"vbox",$widget->getHandle());
    }
$this;	
}

sub action {
	my $this=shift;
	
	print "Actionadd!\n";
	
	while(my $widget=shift) {
	
	  push @{$this->{"widgets"}}, $widget;
	  $this->setWidget($widget);
	
	  htk_xs::htk_dialog_add($this->getHandle(),"action_area",$widget->getHandle());
    }
$this;	
}



################################################################

package htk::Button;

use vars qw(@ISA);
@ISA=qw(htk::Widget);

sub new {
	my $class=shift;
	my $name=shift;
	my $text=shift;
	my $command=shift;
	
	my $this=$class->SUPER::new($name,"htk::Button");
	
	$this->setHandle(htk_xs::htk_button_new($text));
	if ($command) {	$this->setEvent($command,"clicked",$this,@_); }
}

sub setValue {
	my $this=shift;
	my $label=shift;
	
	htk_xs::htk_button_label($this->getHandle(),$label);
}

sub getValue {
	my $this=shift;
	
	return htk_xs::htk_button_get_label($this->getHandle());
}


################################################################

package htk::HBox;

use vars qw(@ISA);
@ISA=qw(htk::Widget);

sub new {
	my $class=shift;
	my $name=shift;
	
	my $this=$class->SUPER::new($name,"htk::HBox");
	
	$this->setHandle(htk_xs::htk_hbox_new(@_));
$this;	
}

################################################################

package htk::VBox;

use vars qw(@ISA);
@ISA=qw(htk::Widget);

sub new {
	my $class=shift;
	my $name=shift;
	
	my $this=$class->SUPER::new($name,"htk::VBox");
	
	$this->setHandle(htk_xs::htk_vbox_new(@_));
$this;	
}

################################################################

package htk::Text;

use vars qw(@ISA);
@ISA=qw(htk::Widget);

sub new {
	my $class=shift;
	my $name=shift;
	my $text=shift;
	
	my $this=$class->SUPER::new($name,"htk::Text");
	
	$this->setHandle(htk_xs::htk_text_new($this->getProp("text")));
	
$this;	
}

################################################################

package htk::Entry;

use vars qw(@ISA);
@ISA=qw(htk::Widget);

sub new {
	my $class=shift;
	my $name=shift;
	my $text=shift;
	
	my $this=$class->SUPER::new($name,"htk::Entry");
	
	$this->setHandle(htk_xs::htk_entry_new($text,@_));
$this;	
}

sub setValue {
	my $self=shift;
	my $text=shift;
	
	htk_xs::htk_entry_set($self->getHandle,$text,@_);
}

sub getValue {
	my $self=shift;
	
	return htk_xs::htk_entry_get($self->getHandle);
}


################################################################

package htk::Label;

use vars qw(@ISA);
@ISA=qw(htk::Widget);

sub new {
	my $class=shift;
	my $name=shift;
	my $label=shift;
	
	my $this=$class->SUPER::new($name,"htk::Label");
	$this->setHandle(htk_xs::htk_label_new($label,@_));
	
$this;	
}

sub setValue {
	my $this=shift;
	my $label=shift;
	
	htk_xs::htk_label_set($this->getHandle(),$label);
}

sub getValue {
	my $this=shift;
	htk_xs::htk_label_get($this->getHandle());
}


1;
