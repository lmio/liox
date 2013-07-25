LIOX, the Linux distribution for LIO2014 
----------------------------------------

Linux distribution for Lithuania Informatics Olympiad 2014.

Getting started
---------------

To generate the ``binary.hybrid.iso``, type::

    $ make

You will need root for ``live build``. Note: this will take a while and download
>800MB from the internet.

Run it::

    $ kvm -boot d -cdrom binary.hybrid.iso

You can also run it via VirtualBox, VMWare, Xen, etc. Just run it as a bootable
CD.

Optionally, you can install this image to a hard drive by selecting "install" in
the installation menu.

Contributing
------------

Please test and contribute by opening the pull request. General
rules/guidelines:

1. Everything that is supposed to be generated should be generated.
2. Keep 80 character limit in non-generated files (READMEs, Makefiles, scripts).
3. Keep it all English.
4. Write `good commit messages`_.

.. _`good commit messages`: https://github.com/erlang/otp/wiki/Writing-good-commit-messages
