package htk;

# log stubs voor de log server om te gebruiken in perl
# Alleen de client functies

use strict;
use vars qw($VERSION);
$VERSION='0.03';

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

	 print $this->getHandle," , ",$widget->getHandle;
	 htk_xs::htk_add_widget($this->getHandle(),$widget->getHandle());
	 print " --> ok\n";
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

sub Destroy {
	my $self=shift;

	htk_xs::htk_widget_destroy($self->getHandle);
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
    my $title=shift;
    my $args = { 'ALLOW_SHRINK' => 1, 'ALLOW_GROW' => 1, 'AUTO_SHRINK' => 1, 'TYPE' => undef, @_ };

	my $this=$class->SUPER::new($name,"htk::Window");
	
	$this->{"windowtype"}=$args->{'TYPE'};

	if (not $this->{"windowtype"}) {
		$this->{"windowtype"}=htk_xs::htk_window_toplevel();
	}

	$this->setHandle(htk_xs::htk_window_new($this->{"windowtype"}));
	$this->setValue($title);

	print $args->{'ALLOW_SHRINK'},",",$args->{'ALLOW_GROW'},",",$args->{'AUTO_SHRINK'},"\n";

        htk_xs::htk_window_set_policy($this->getHandle,
                                            $args->{'ALLOW_SHRINK'},
					    $args->{'ALLOW_GROW'},
					    $args->{'AUTO_SHRINK'}
				     );


$this;	
}

sub setValue {
  my $self=shift;
  my $title=shift;
  htk_xs::htk_window_set_title($self->getHandle,$title);
  $self->SUPER::setValue($title);
}


################################################################

package htk::Grid;

use vars qw(@ISA);
@ISA=qw(htk::Widget);

sub new {
  my $class=shift;
  my $name=shift;
  my $rows=shift;
  my $cols=shift;

     my $this=$class->SUPER::new($name,"htk::Grid");

     $this->setHandle(htk_xs::htk_grid_new($rows,$cols));

$this;
}

################################################################

package htk::Dialog;

use vars qw(@ISA);
@ISA=qw(htk::Window);

sub new {
	my $class=shift;
	my $name=shift;
	my $title=shift;
	my $rows=shift;
	my $cols=shift;

        if (not $rows)  { $rows=2; }
        if (not $cols)  { $cols=2; }
        if (not $title) { $title="Dialog has no title"; }

	my $this=$class->SUPER::new($name, $title, 'ALLOW_SHRINK' => 0, 'ALLOW_GROW' => 0 );
	$this->{'dlgGRID'}=new htk::VBox($name.".grid",$rows,$cols);
	$this->SUPER::add($this->{'dlgGRID'});

$this;	
}

sub add {
   my $this=shift;
	$this->{'dlgGRID'}->add(@_);
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
