class Vls.TextDocument : Object {
    public weak Compilation compilation { get; private set; }
    public string filename { get; private set; }

    public Vala.SourceFile file { get; private set; }
    public string uri { get; private set; }
    public int version;

    public string? content {
        get {
            // Vala.SourceFile.get_mapped_contents () returns
            // file.content if it's non-null
            return (string) file.get_mapped_contents ();
        }
        set {
            file.content = value;
        }
    }

    public bool is_writable { get; private set; }

    public TextDocument (Compilation compilation,
                         string filename,
                         bool is_writable = true,
                         string? content = null,
                         int version = 0) throws ConvertError, FileError {

        if (!FileUtils.test (filename, FileTest.EXISTS)) {
            throw new FileError.NOENT ("file %s does not exist".printf (filename));
        }

        this.compilation = compilation;
        this.filename = filename;
        this.uri = Filename.to_uri (filename);
        this.version = version;
        this.is_writable = is_writable;

        var type = Vala.SourceFileType.NONE;
        if (uri.has_suffix (".vala") || uri.has_suffix (".gs"))
            type = Vala.SourceFileType.SOURCE;
        else if (uri.has_suffix (".vapi") || uri.has_suffix (".gir"))
            type = Vala.SourceFileType.PACKAGE;

        this.file = new Vala.SourceFile (compilation.code_context, type, filename, content);
    }

    /**
     * Create a TextDocument that wraps a Vala.SourceFile
     */
    public TextDocument.from_sourcefile (Compilation compilation,
                                         Vala.SourceFile file,
                                         bool is_writable = true) throws ConvertError {
        this.compilation = compilation;
        this.filename = file.filename;
        this.uri = Filename.to_uri (file.filename);
        this.version = 0;
        this.file = file;
        this.is_writable = is_writable;
    }
}
