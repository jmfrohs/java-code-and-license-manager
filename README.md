# Java Code Formatter & License Manager

Professional Windows batch formatter for Java code with Google Java Format. Automatic license headers, backup system, drag and drop support, and configurable settings. 

## Features

### Code Formatting
- Automatic Java code formatting with Google Java Format
- Support for .java and .txt files containing Java code
- Flexible formatting options: Google style or AOSP style
- Batch processing: single files, directories, or recursive formatting
- Drag and drop support for easy operation

### License Management
- Automatic addition of license headers to Java files
- Predefined license templates: MIT, Apache-2.0, GPL-3.0, Custom
- Create and manage individual license templates
- Automatic placeholder replacement for year, author, and company
- Intelligent license detection prevents duplicates

### Advanced Features
- Backup system with automatic recovery on errors
- Code validation without formatting
- Detailed logging of all formatting activities
- Code statistics and file analysis
- Configurable settings with persistent storage
- Automatic download function for Google Java Format JAR

## Prerequisites

- Windows 10/11 (PowerShell for JAR download)
- Java 8 or higher (must be available in PATH)
- Internet connection (for initial JAR file download)

## Installation

1. Clone repository or download ZIP:
```bash
git clone https://github.com/yourusername/java-code-formatter.git
cd java-code-formatter
```

2. Run the batch script:
```batch
java_formatter.bat
```

3. On first run, the Google Java Format JAR file will be downloaded automatically.

## Usage

### Basic Formatting

```batch
# Start the script
java_formatter.bat

# Choose options:
[1] Format current directory
[2] Format specific directory
[3] Format single file
[4] Format all subdirectories recursively
```

### Advanced Features

```batch
# Add license headers
[D] Add license headers

# Code validation
[8] Code validation without formatting

# Configure settings
[9] Configure settings
```

### Drag and Drop Mode

```batch
[7] Drag & Drop mode
# Simply drag files onto the script
```

## Configuration

The tool automatically creates a `formatter_config.ini` with the following settings:

```ini
CREATE_BACKUP=true
ENABLE_LOGGING=true
FORMATTER_STYLE=Google
INDENT_SIZE=2
DEFAULT_LICENSE=MIT
AUTHOR_NAME=Your Name
COMPANY_NAME=Your Company
AUTO_UPDATE_YEAR=true
AUTO_ADD_LICENSE=true
```

### Configurable Options

| Option | Description | Values |
|--------|-------------|--------|
| `CREATE_BACKUP` | Create backup before formatting | `true/false` |
| `ENABLE_LOGGING` | Enable logging | `true/false` |
| `FORMATTER_STYLE` | Code style | `Google/AOSP` |
| `INDENT_SIZE` | Indentation in spaces | `2-8` |
| `DEFAULT_LICENSE` | Default license | `MIT/Apache-2.0/GPL-3.0/Custom` |
| `AUTHOR_NAME` | Author for license headers | Any text |
| `COMPANY_NAME` | Company for license headers | Any text |
| `AUTO_UPDATE_YEAR` | Automatically update year | `true/false` |
| `AUTO_ADD_LICENSE` | Automatically add license | `true/false` |

## License Templates

### Predefined Licenses

- **MIT License** - Permissive open source license
- **Apache 2.0** - Apache Software Foundation license
- **GPL 3.0** - GNU General Public License
- **Custom** - User-defined proprietary license

### Custom License Templates

Create your own templates in `license_templates.txt`:

```
[MyLicense]
/*
 * My Custom License
 * Copyright (c) {YEAR} {AUTHOR}
 * {COMPANY} - All rights reserved
 */
```

**Available Placeholders:**
- `{YEAR}` - Current year
- `{AUTHOR}` - Configured author
- `{COMPANY}` - Configured company

## Logging and Statistics

### Log File
All formatting activities are logged in `formatter_log.txt`:

```
15.06.2025 14:30:15 - Formatting: C:\Dev\MyProject\Main.java
15.06.2025 14:30:16 - Success: C:\Dev\MyProject\Main.java
15.06.2025 14:30:17 - License added: C:\Dev\MyProject\Main.java
```

### Code Statistics
The tool can analyze various metrics:
- Number of Java files
- Number of TXT files
- Total lines
- Total characters

## Advanced Functions

### Code Validation
Check Java syntax without formatting:
```batch
[8] Code validation without formatting
# Shows syntax errors without changing code
```

### Backup Management
```batch
[A] Clean up backup files
# Removes all .backup files
```

### Combined Operations
```batch
[F] Format + Add License
# Formats code AND adds license in one step
```

## Troubleshooting

### Common Problems

**Java not found:**
```
ERROR: Java is not installed or not available in PATH!
```
**Solution:** Install Java and add to PATH.

**JAR download failed:**
```
ERROR: Download failed!
```
**Solution:** Download JAR manually from [Google Java Format Releases](https://github.com/google/google-java-format/releases)

**Syntax error in TXT file:**
```
ERROR: File may contain invalid Java code
```
**Solution:** Use code validation to identify syntax issues.

### Debug Tips

1. **Enable logging** for detailed error analysis
2. **Use backup function** to protect against data loss
3. **Run code validation** before formatting
4. **Check log file** for unexpected problems

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Create a Pull Request

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Google Java Format](https://github.com/google/google-java-format) - The underlying code formatter
- [Apache Software Foundation](https://www.apache.org/) - For the Apache license template
- Community contributions and feedback

## Support

For questions or issues:

- Create [Issues](https://github.com/yourusername/java-code-formatter/issues)
- Start [Discussions](https://github.com/yourusername/java-code-formatter/discussions)
- Email: your.email@example.com

---

**Made with care for the Java community**
