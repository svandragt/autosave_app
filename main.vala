using Gtk;
using GLib;

public class MyWindow: Gtk.Window {

    private TextView text_view;
    private string app_dir;
    private string filename;
    private uint save_source_id = 0;

    public MyWindow() {
        this.title = "Autosave App";
        this.window_position = Gtk.WindowPosition.CENTER;
        this.set_default_size(500, 500);
        this.destroy.connect(Gtk.main_quit);

        app_dir = GLib.Environment.get_user_data_dir() + "/autosave_app";
        filename = app_dir + "/autosave.txt";
        // Create directory
        var dir = GLib.File.new_for_path(app_dir);
        try {
            if (!dir.query_exists()) {
                dir.make_directory_with_parents();
            }
        } catch (GLib.Error e) {
            GLib.print("Failed to create directory: %s\n", e.message);
        }
        
        /* Setup text view widget */
        this.text_view = new TextView();
        this.text_view.wrap_mode = WrapMode.WORD_CHAR;
        this.text_view.border_width = 0; // No margins
        var scrolled_window = new ScrolledWindow(null, null);
        scrolled_window.add(this.text_view);
        /* Set padding for the text view widget */
        try {
         var css = new CssProvider();
         css.load_from_data("* { font: 12px 'Roboto Mono', monospace; padding: 10px; }");
         var style_context = this.text_view.get_style_context();
         style_context.add_provider(css, STYLE_PROVIDER_PRIORITY_APPLICATION);
         } catch (Error e) {
            print("Failed to load CSS: %s\n", e.message);
         }

        this.add(scrolled_window);

        size_t length;
        string content;
        try {
            FileUtils.get_contents(filename, out content, out length);
            this.text_view.get_buffer().set_text(content, -1);
        } catch (FileError e) {
            print("Couldn't load the contents of the file. Program will start with an empty textbox!");
        }

        /* Setup auto save */
        this.text_view.buffer.changed.connect(on_buffer_changed);
    }

    private void on_buffer_changed() {
        if (this.save_source_id != 0)
            Source.remove(this.save_source_id);

        this.save_source_id = GLib.Timeout.add_seconds(1, autosave);
    }

    private bool autosave() {
        TextIter start, end;

        /* Get text between the start and end of the buffer */
        this.text_view.buffer.get_bounds(out start, out end);
        string text = this.text_view.buffer.get_text (start, end, false);

        try {
            FileUtils.set_contents(filename, text);
        } catch (FileError e) {
            print("Auto save failed!");
        }

        this.save_source_id = 0;
        return false; /* Remove this source */
    }

    public static int main(string[] args) {
        Gtk.init(ref args);

        MyWindow window = new MyWindow();
        window.show_all();

        Gtk.main();

        return 0;
    }
}
