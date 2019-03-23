## Usage

```sh
# Install needed system dependencies.
sudo pacman -S gnu-efi-libs efibootmgr

# Build the EFI and create an image.
./build.sh

# Flash the image onto a storage device, e.g. /dev/sda.
sudo dd if=hello.img of=/dev/sda bs=1M
```
