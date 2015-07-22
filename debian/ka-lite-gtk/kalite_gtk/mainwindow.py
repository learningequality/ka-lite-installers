from gi.repository import Gtk, Gdk
from pkg_resources import resource_filename
import gobject
import shlex
import subprocess


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
        return func_hl

    return async_func


class Handler:

    def __init__(self, mainwindow):
        self.mainwindow = mainwindow

    def on_delete_window(self, *args):
        Gtk.main_quit(*args)

    def on_start_button_pressed(self, button):
        self.mainwindow.log_message("Starting KA Lite...")
        self.exec_and_log("kalite start")

    @run_async
    def exec_and_log(self, cmd, shell=False):
        if not shell:
            args = shlex.split(cmd)
        else:
            args = cmd
        self.process = subprocess.Popen(args, stdout=subprocess.PIPE,
                                        stderr=subprocess.STDOUT, shell=shell,)
        self.process.wait()
        stdout = self.process.stdout.readline()
        gobject.idle_add(self.mainwindow.log_message, stdout)


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

    def log_message(self, msg):
        self.log.insert_at_cursor(msg)


if __name__ == "__main__":
    win = MainWindow()
    Gtk.main()
