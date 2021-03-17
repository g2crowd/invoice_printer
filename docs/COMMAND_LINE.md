# InvoicePrinter CLI

InvoicePrinter ships with a command line executable called `invoice_printer`.

It supports all features except it only accepts JSON as an input.

```
$ invoice_printer --help
Usage: invoice_printer [options]

Options:

  -d, --document   document as JSON
    -l, --labels   labels as JSON
          --font   path to font or builtin font name
     -s, --stamp   path to stamp
          --logo   path to logotype
    --background   path to background image
  -f, --filename   output path
    -r, --render   directly render PDF stream (filename option will be ignored)
```

## Document

JSON document with all possible fields filled:

```json
{
   "number":"c. 198900000001",
   "provider_name":"Petr Novy",
   "provider_lines":"Rolnická 1\n747 05  Opava\nKateřinky",
   "purchaser_name":"Adam Cerny",
   "purchaser_lines":"Ostravská 1\n747 70  Opava",
   "issue_date":"05/03/2016",
   "due_date":"19/03/2016",
   "subtotal":"Kc 10.000",
   "tax":"Kc 2.100",
   "variable":"Extra column",
   "total":"Kc 12.100,-",
   "items":[
      {
         "name":"Konzultace",
         "variable": "",
         "quantity":"2",
         "unit":"hod",
         "price":"Kc 500",
         "tax":"",
         "amount":"Kc 1.000"
      },
      {
         "name":"Programovani",
         "variable": "",
         "quantity":"10",
         "unit":"hod",
         "price":"Kc 900",
         "tax":"",
         "amount":"Kc 9.000"
      }
   ],
   "note":"Osoba je zapsána v zivnostenském rejstríku."
}
```

**Note**: `provider_lines` and `purchaser_lines` are 4 lines of data separated by new line character`\n`. Other lines are being stripped.

**Note**: There is `variable` field that can be used for any
extra column.

## Field labels

All labels:

```json
{
  "name":"Invoice",
  "provider":"Provider",
  "purchaser":"Purchaser",
  "tax_id":"Identification number",
  "tax_id2":"Identification number",
  "issue_date":"Issue date",
  "due_date": "Due date",
  "item":"Item",
  "variable":"",
  "quantity":"Quantity",
  "unit": "Unit",
  "price_per_item":"Price per item",
  "amount":"Amount",
  "tax":"Tax",
  "subtotal":"Subtotal",
  "total":"Total",
  "sublabels":{
    "name":"Faktura",
    "provider":"Prodejce",
    "purchaser":"Kupující",
    "tax_id":"IČ",
    "tax_id2":"DIČ",
    "issue_date":"Datum vydání",
    "due_date":"Datum splatnosti",
    "item":"Položka",
    "variable:":"",
    "quantity":"Počet",
    "unit":"MJ",
    "price_per_item":"Cena za položku",
    "amount":"Celkem bez daně",
    "subtota":"Cena bez daně",
    "tax":"DPH 21 %",
    "total":"Celkem"
  }
}
```
**Note**: Notice the `sublabels` which you might not want to necessary include.

## Built-in fonts

Supported builtin fonts are: `overpass`, `opensans`, and `roboto`.

## Examples

```
$ invoice_printer --document '{"number":"c. 198900000001","provider_name":"Petr Novy","provider_lines":"Rolnická 1\n747 05  Opava\nKateřinky","purchaser_name":"Adam Cerny","purchaser_lines":"Ostravská 1\n747 70  Opava","issue_date":"05/03/2016","due_date":"19/03/2016","subtotal":"Kc 10.000","tax":"Kc 2.100","total":"Kc 12.100,-","items":[{"name":"Konzultace","quantity":"2","unit":"hod","price":"Kc 500","tax":"","amount":"Kc 1.000"},{"name":"Programovani","quantity":"10","unit":"hod","price":"Kc 900","tax":"","amount":"Kc 9.000"}],"note":"Osoba je zapsána v zivnostenském rejstríku."}' --font Overpass-Regular.ttf --filename out.pdf
```
