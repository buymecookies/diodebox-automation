# diodebox-automation
Raspberry Pi OS with desktop

    Release date: March 15th 2024
    System: 64-bit
    Kernel version: 6.6
    Debian version: 12 (bookworm)
    Size: 1,105MB
    sha: 7e53a46aab92051d523d7283c080532bebb52ce86758629bf1951be9b4b0560f

## installation

  - flash Raspberry Pi OS with desktop to the SD card
  - copy a valid userconf.txt file & create an empty file named 'ssh' in the boot partition
  - (ssh-copy-id) your keys to the host [optional]
  - run the playbook:
    ansible-playbook -i inventory/ site.yml ["-k" if no keys have been copied] 
