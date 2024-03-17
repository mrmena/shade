# shade

shade is a command-line tool for changing the color of text output in the terminal. It allows you to adjust the brightness and color of text to enhance readability or create visual effects.

## Features

- Adjust text brightness to improve readability
- Change text color to highlight important information
- Support for various color options
- Simple and intuitive command-line interface

## Installation

### Requirements

- [Bash](https://www.gnu.org/software/bash/) (version 4.0 or later)
- [Getopt](https://linux.die.net/man/1/getopt) (typically available on Unix-like systems)

### Instructions

1. Clone the Shade repository:

   ```bash
   git clone https://github.com/mrmena/shade.git
   ```

2. Navigate to the Shade directory:

   ```bash
   cd shade
   ```

3. Make the shade script executable:

   ```bash
   chmod +x shade
   ```

4. Add the Shade directory to your PATH (optional):

   ```bash
   export PATH="$PATH:/path/to/shade"
   ```

## Usage

shade can be used to modify the color and brightness of text output in the terminal. Here are some examples:

     ```bash
     # Ping output is shaded
     ping mrmena.com | shade cyan
  
     # Ping output with alternating colours (long params)
     ping mrmena.com | shade green --count 2 --delta 128
  
     # Adjust text brightness and colour (short params)
     ls -al | shade -c 10 -d 20
  
     # Display help message
     shade --help
     ```

For more information on how to use Shade, refer to the documentation.

## Contributing

Contributions to shade are welcome! If you find any issues or have suggestions for improvements, feel free to open an issue or submit a pull request on the GitHub repository.

## License

shade is licensed under the MIT License.
