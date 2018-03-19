<img src="./assets/logo.png" width="300" />

&nbsp;

**Super simple PDF invoicing.** InvoicePrinter is a server, command line program and pure Ruby library to generate PDF invoices in no time. You can use Ruby or JSON as the invoice representation to build the final PDF.

| Simple invoice |
| -------------- |
| <a href="https://github.com/strzibny/invoice_printer/raw/master/examples/promo.pdf"><img src="./examples/picture.jpg" width="180" /></a>|

See more usecases in the `examples/` directory.

## Features

- A4 and US letter paper size
- Invoice/document name and number
- Purchaser and provider boxes with addresses and identificaton numbers
- Payment method box showing banking details including SWIFT and IBAN fields
- Issue/due dates box
- Configurable items' table with item description, quantity, unit, price per unit, tax and item's total amount fields
- Final subtotal/tax/total info box
- Page numbers
- Configurable labels & sublabels (optional little labels)
- Configurable font file
- Logotype (as image scaled to fit 50px of height)
- Background (as image)
- Stamp & signature (as image)
- Note
- JSON format
- CLI
- Server
- Well tested

## Documentation

- [Installation](./docs/INSTALLATION.md)
- [Library](./docs/LIBRARY.md)
- [Server](./docs/SERVER.md)
- [Command line](./docs/COMMAND_LINE.md)

## Copyright

Copyright 2015-2017 &copy; [Josef Strzibny](http://strzibny.name/). MIT licensed.

Originally extracted from and created for an open source single-entry invoicing app [InvoiceBar](https://github.com/strzibny/invoicebar).
