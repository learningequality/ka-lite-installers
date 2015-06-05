from gi.repository import Gtk, Gdk
from pkg_resources import resource_filename


class Handler:
    def onDeleteWindow(self, *args):
        Gtk.main_quit(*args)

    def onButtonPressed(self, button):
        print("Hello World!")


class MainWindow:

    def __init__(self):

        self.builder = Gtk.Builder()
        glade_file = resource_filename(__name__, "glade/mainwindow.glade")
        self.builder.add_from_file(glade_file)
        self.builder.connect_signals(Handler())

        self.window = self.builder.get_object("mainwindow")
        self.window.show_all()
        
        self.log_textview = self.builder.get_object("log_textview")
        
        # Style the log like a terminal
        self.log_textview.override_background_color(Gtk.StateFlags.NORMAL, Gdk.RGBA(0, 0, 0, 1))
        self.log_textview.override_color(Gtk.StateFlags.NORMAL, Gdk.RGBA(1, 1, 1, 1))


if __name__ == "__main__":
    win = MainWindow()
    Gtk.main()
