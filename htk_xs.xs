#include <gtk/gtk.h>

#include <EXTERN.h>
#include <perl.h>

#ifdef __WIN32__
#undef pipe
#endif

#include <XSUB.h>

static 
void htk_callback(GtkWidget *widget,gpointer function) 
{
char *func=(char *)  function;


  {
    dSP;
  
    ENTER;
    SAVETMPS;
  
    PUSHMARK(SP);
  
    XPUSHs(sv_2mortal(newSVpv(func,0)));
    PUTBACK;
  
    call_pv("htk::callBack",G_DISCARD);
  
    FREETMPS;
    LEAVE;
  }
}

static gint htk_timer_callback(gpointer *function)
{
char *func=(char *) function;
int   count;
gint  ok;

  dSP;
  
  ENTER;
  SAVETMPS;
  
  PUSHMARK(SP);
  
  XPUSHs(sv_2mortal(newSVpv(func,0)));
  PUTBACK;
  
  count=call_pv("htk::callBack",G_SCALAR);
  
  SPAGAIN;
  
  if (count!=1) {
	  croak("Timer function should return 0 (false) to terminate or 1 (true) otherwise\n");
  }
  
  ok=POPi;

  PUTBACK;  
  FREETMPS;
  LEAVE;
  
return ok;  
}


static 
void init(void)
{
static int init=1;
  if (init) {
    init=0;
    gtk_init(0,NULL);
  }
}

static
int _justify(char *j)
{
  if (strcmp(j,"left")==0)       { return GTK_JUSTIFY_LEFT; }
  else if (strcmp(j,"right")==0) { return GTK_JUSTIFY_RIGHT; }
  else if (strcmp(j,"fill")==0)  { return GTK_JUSTIFY_FILL; }
  else                           { return GTK_JUSTIFY_CENTER; }
}


static
void quit(void) 
{
   gtk_main_quit();
}

static
void add_widget(void *widget, void *add)
{
    gtk_container_add(GTK_CONTAINER((GtkWidget *) widget),(GtkWidget *) add);    	
}


MODULE = htk_xs		PACKAGE = htk_xs
PROTOTYPES: Enable


void htk_main()
	CODE:
	  gtk_main();



	  
void htk_widget_show(window)
		void *window;
	CODE:
        init();
		gtk_widget_show((GtkWidget *) window);
		
void htk_widget_show_all(widget)
		void *widget;
	CODE:
		init();
		gtk_widget_show_all((GtkWidget *) widget);
				

void htk_add_widget(widget,add)
        void *widget;
        void *add;
    CODE:
        init();
        add_widget(widget,add);
        

void htk_set_event(widget,function,event)
		void *widget;
		char *function;
		char *event;
	CODE:
        init();
		gtk_signal_connect(GTK_OBJECT(widget),event,GTK_SIGNAL_FUNC(htk_callback),function);
		
int htk_set_timer(millisecs, function)
		int   millisecs;
		char *function;
	CODE:
		init();
		RETVAL=gtk_timeout_add(millisecs,htk_timer_callback,function);
	OUTPUT:
		RETVAL
		
		
int htk_window_toplevel()
    CODE:
        init();
        RETVAL=(int) GTK_WINDOW_TOPLEVEL;
    OUTPUT:
        RETVAL    

void *htk_window_new(type)
		int type;
		GtkWindowType t=(GtkWindowType) type;
	CODE:
        init();
	    RETVAL=(void *) gtk_window_new(t);
        gtk_signal_connect (GTK_OBJECT (RETVAL), "delete_event", GTK_SIGNAL_FUNC (quit), NULL);
	OUTPUT:
   		RETVAL

void htk_quit()
	CODE:
		quit();
		   		
   		
   		   		
void *htk_button_new(label)
        char *label;
    CODE:
        init();
        RETVAL=(void *) gtk_button_new_with_label(label);
    OUTPUT:
    	RETVAL
    	
void htk_button_label(widget,label)
		void *widget;
		char *label;
	CODE:
		init();
		{
		  GtkObject *b=(GtkObject *) widget;
		  gtk_object_set(b,"label",label,NULL);
        }
        
char *htk_button_get_label(widget)
		void *widget;
	CODE:
		init();
		{
		  const char *s;
		  GtkObject *b=(GtkObject *) widget;
		  GtkArg     A;
		  	A.name="label";
		  	gtk_object_getv(b,1,&A);
		  	RETVAL=GTK_VALUE_STRING(A);
		}
 	OUTPUT:
 		RETVAL
	
		        
                


void *htk_dialog_new(modal=1)
		int modal;
	CODE:
		init();
		RETVAL=(void *) gtk_dialog_new();		
		gtk_window_set_modal(GTK_WINDOW(RETVAL),modal);
	OUTPUT:
		RETVAL

		
void htk_dialog_add(widget,area="vbox",add)
		void *widget;
		char *area;
		void *add;
	CODE:
		init();
		{ GtkDialog *dlg=(GtkDialog *) widget;
		  if (strcmp(area,"vbox")==0) {
			add_widget((void *) dlg->vbox,add);
		  }
		  else {
			add_widget((void *) dlg->action_area,add);
		  }
		}
		
		
		
void *htk_text_new(text,editable=1)
		char *text;
		int   editable;
	CODE:
		init();
		{GtkText *txt=(GtkText *) gtk_text_new(NULL,NULL);
		  gtk_text_set_editable(txt,editable);
		  RETVAL=(void *) txt;
	        }
	OUTPUT:
		RETVAL
    	

		
void *htk_entry_new(text,editable=1)
		char *text;
		int   editable;
	CODE:
		init();
		{ GtkEntry *txt=(GtkEntry *) gtk_entry_new();
		    gtk_entry_set_text(txt,text);
		    gtk_editable_set_editable(txt,editable);
		    RETVAL=(void *) txt;
		}
	OUTPUT:
		RETVAL
		
void htk_entry_set(entry,text,editable=1)
 		void *entry;
		char *text;
		int   editable;
	CODE:
		init();
		{
		  gtk_entry_set_text((GtkEntry *) entry,text);
		  gtk_editable_set_editable((GtkEntry *) entry, editable);
		}
		
char *htk_entry_get(entry)
		void *entry;
	CODE:
		init();
		{
			RETVAL=gtk_entry_get_text((GtkEntry *) entry);
		}		
	OUTPUT:
		RETVAL
		
		
		
void *htk_label_new(label,justify="left")
		char *label;
		char *justify;
	CODE:
		init();
		{
		  GtkLabel *L;
		      L=(GtkLabel *) gtk_label_new(strdup(label));
			  gtk_label_set_justify(L,_justify(justify));
			  RETVAL=(void *) L;
		}
	OUTPUT:
		RETVAL
		
void htk_label_set(label, text, justify="left")
        void *label;
		char *text;
		char *justify;
	CODE:
		init();
		gtk_label_set_text((GtkLabel *) label,text);
				
char *htk_label_get(label)
		void *label;
	CODE:
		{
		  char *s;
		    gtk_label_get((GtkLabel *) label,&s);
		    RETVAL=s;
		}
	OUTPUT:
		RETVAL
						
		
void *htk_hbox_new(homogenous=0,spacing=1)
		int homogenous;
		int spacing;
	CODE:
		init();
		RETVAL=(void *) gtk_hbox_new(homogenous,spacing);
	OUTPUT:
		RETVAL
		
		
void *htk_vbox_new(homogenous=0,spacing=1)
		int homogenous;
		int spacing;
	CODE:
		init();
		RETVAL=(void *) gtk_vbox_new(homogenous,spacing);
	OUTPUT:
		RETVAL
				
		
