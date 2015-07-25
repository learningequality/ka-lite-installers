from __future__ import print_function
from __future__ import unicode_literals

from gi.repository import Gtk, Gdk, GLib
from pkg_resources import resource_filename  # @UnresolvedImport
import logging

from . import cli


logger = logging.getLogger(__name__)


def run_async(func):
    """
    http://code.activestate.com/recipes/576684-simple-threading-decorator/

        run_async(func)
            function decorator, intended to make "func" run in a separate
            thread (asynchronously).
            Returns the created Thread object

            E.g.:
            @run_async
            def task1():
                do_something

            @run_async
            def task2():
                do_something_too

            t1 = task1()
            t2 = task2()
            ...
            t1.join()
            t2.join()
    """
    from threading import Thread
    from functools import wraps

    @wraps(func)
    def async_func(*args, **kwargs):
        func_hl = Thread(target=func, args=args, kwargs=kwargs)
        func_hl.start()
        # Never return anything, idle_add will think it should re-run the
        # function because it's a non-False value.
        return None

    return async_func


class Handler:

    def __init__(self, mainwindow):
        self.mainwindow = mainwindow

    def on_delete_window(self, *args):
        Gtk.main_quit(*args)

    @run_async
    def on_start_button_clicked(self, button):
        self.mainwindow.log_message("Starting KA Lite...")
        for stdout, stderr in cli.stream_kalite_command("start"):
            GLib.idle_add(self.mainwindow.log_message, stdout)
        if stderr:
            GLib.idle_add(self.mainwindow.log_message, stderr)
        GLib.idle_add(self.mainwindow.update_status)
    
    @run_async
    def on_stop_button_clicked(self, button):
        self.mainwindow.log_message("Stopping KA Lite...")
        for stdout, stderr in cli.stream_kalite_command("stop"):
            if stdout:
                GLib.idle_add(self.mainwindow.log_message, stdout)
        if stderr:
            GLib.idle_add(self.mainwindow.log_message, stderr)
        GLib.idle_add(self.mainwindow.update_status)

    def on_main_notebook_change_current_page(self, *args, **kwargs):
        print(args, kwargs)

    def settings_changed(self, widget):
        """
        We should make individual handlers for widgets, but this is easier...
        """
        cli.save_settings()


class MainWindow:

    def __init__(self):

        self.builder = Gtk.Builder()
        glade_file = resource_filename(__name__, "glade/mainwindow.glade")
        self.builder.add_from_file(glade_file)

        self.window = self.builder.get_object("mainwindow")
        self.builder.connect_signals(Handler(self))

        self.window.show_all()

        self.log_textview = self.builder.get_object("log_textview")
        self.log = self.builder.get_object("log")

        # Style the log like a terminal
        self.log_textview.override_background_color(
            Gtk.StateFlags.NORMAL, Gdk.RGBA(0, 0, 0, 1))
        self.log_textview.override_color(
            Gtk.StateFlags.NORMAL, Gdk.RGBA(1, 1, 1, 1))

        self.diagnose_textview = self.builder.get_object("diagnose_textview")
        self.diagnostics = self.builder.get_object("diagnostics")

        # Style the log like a terminal
        self.diagnose_textview.override_background_color(
            Gtk.StateFlags.NORMAL, Gdk.RGBA(0, 0, 0, 1))
        self.diagnose_textview.override_color(
            Gtk.StateFlags.NORMAL, Gdk.RGBA(1, 1, 1, 1))
        
        self.set_from_settings()
        
        GLib.idle_add(self.update_status)
        GLib.timeout_add(60 * 1000, lambda: self.update_status or True)
        
        self.status_entry = self.builder.get_object('status_label')

    def log_message(self, msg):
        self.log.insert_at_cursor(msg)
    
    def set_from_settings(self):
        default_user_radio_button = self.builder.get_object('radiobutton_user_default')
        label = default_user_radio_button.get_label()
        label = label.replace('{default}', cli.DEFAULT_USER)
        default_user_radio_button.set_label(label)
        
        if cli.DEFAULT_USER != cli.settings['user']:
            self.builder.get_object('username_entry').set_text(cli.settings['user'])
            self.builder.get_object('radiobutton_username').set_active(True)
    
    @run_async
    def update_status(self):
        GLib.idle_add(self.set_status, "Updating status...")
        GLib.idle_add(self.set_status, "Server status: " + (cli.status() or "Error fetching status").split("\n")[0])
    
    def set_status(self, status):
        self.status_entry.set_label(status)


if __name__ == "__main__":
    win = MainWindow()
    Gtk.main()
