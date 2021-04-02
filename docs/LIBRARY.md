# InvoicePrinter Library

## Usage

The simplest way how to create your invoice PDF is to create an invoice object
and pass it to printer:

```ruby
item = InvoicePrinter::Document::Item.new(
  ...
)

invoice = InvoicePrinter::Document.new(
  ...
  items: [item, ...]
)

InvoicePrinter.print(
  document: invoice,
  file_name: 'invoice.pdf'
)

# Or render PDF directly
InvoicePrinter.render(
  document: invoice
)
```

Here is an full example for creating the document object:

```ruby
item = InvoicePrinter::Document::Item.new(
  name: 'Web consultation',
  quantity: nil,
  unit: 'hours',
  price: '$ 25',
  tax: '$ 1',
  amount: '$ 100'
)

provider_address = <<~ADDRESS
  Rolnická 1
  747 05  Opava
  Kateřinky
ADDRESS

invoice = InvoicePrinter::Document.new(
  number: '201604030001',
  provider_name: 'Business s.r.o.',
  provider_lines: provider_address,
  purchaser_name: 'Adam',
  purchaser_lines: "Ostravská 1\n747 70  Opava",
  issue_date: '19/03/3939',
  due_date: '19/03/3939',
  subtotal: '175',
  tax: '5',
  total: '$ 200',
  items: [item],
  note: 'A note...'
)
```

**Note**: `provider_lines` and `purchaser_lines` are 4 lines of data separated by new line character`\n`. Other lines are being stripped.

**Note**: There is `variable` field that can be used for any
extra column.

### Ruby on Rails

If you want to use InvoicePrinter for printing PDF documents directly from Rails actions, you can:

```ruby
# GET /invoices/1
def show
  invoice = InvoicePrinter::Document.new(...)

  respond_to do |format|
    format.pdf {
      @pdf = InvoicePrinter.render(
        document: invoice
      )
      send_data @pdf, type: 'application/pdf', disposition: 'inline'
    }
  end
end
```

### JSON format

JSON format is supported via `from_json` method. JSON itself mimicks the original Ruby objects:

```ruby
json = InvoicePrinter::Document.new(...).to_json
document = InvoicePrinter::Document.from_json(json)


InvoicePrinter.print(
  document:  document,
  ...
)
```

## Customization

### Localization

To localize your documents you can set both global defaults or instance
overrides:

```ruby
InvoicePrinter.labels = {
  provider: 'Dodavatel'
}

labels = {
  purchaser: 'Customer'
}

InvoicePrinter.print(
  document: invoice,
  labels: labels,
  file_name: 'invoice.pdf'
)
```

Here is the full list of labels to configure. You can paste and edit this block to `initializers/invoice_printer.rb` if you are using Rails.

```ruby
InvoicePrinter.labels = {
  name: 'Invoice',
  provider: 'Provider',
  purchaser: 'Purchaser',
  tax_id: 'Identification number',
  tax_id2: 'Identification number',
  issue_date: 'Issue date',
  due_date: 'Due date',
  item: 'Item',
  variable: '',
  quantity: 'Quantity',
  unit: 'Unit',
  price_per_item: 'Price per item',
  amount: 'Amount',
  tax: 'Tax',
  subtotal: 'Subtotal',
  total: 'Total'
}
```
**Note:** `variable`  fields lack default label. You should provide one.

You can also use sublabels feature to provide the document in two languages:

```ruby
labels = {
  ...
}

sublabels = {
  name: 'Faktura',
  provider: 'Prodejce',
  purchaser: 'Kupující',
  tax_id: 'IČ',
  tax_id2: 'DIČ',
  issue_date: 'Datum vydání',
  due_date: 'Datum splatnosti',
  item: 'Položka',
  variable: '',
  quantity: 'Počet',
  unit: 'MJ',
  price_per_item: 'Cena za položku',
  amount: 'Celkem bez daně',
  subtotal: 'Cena bez daně',
  tax: 'DPH 21 %',
  total: 'Celkem'
}

labels.merge!({ sublabels: sublabels })

...
```

Now the document will have little sublabels next to the original labels in Czech.

### Font

To support specific characters you might need to specify a TTF font to be used:

```ruby
InvoicePrinter.print(
  ...
  font: File.expand_path('../Overpass-Regular.ttf', __FILE__)
)
```

If you don't have a font around, you can install `invoice_printer_fonts` gem and specify the supported font name instead:

```ruby
InvoicePrinter.print(
  document: invoice,
  font: "roboto"
)
```

Supported builtin fonts are: `overpass`, `opensans`, and `roboto`. Note that searching the path takes preference.

### Background

To include a background image you might need to create the file according to the size and resolution to be used (see: [examples/background.png](https://github.com/strzibny/invoice_printer/blob/master/examples/background.png)):

``` ruby
InvoicePrinter.print(
  ...
  background: File.expand_path('../background.png', __FILE__)
)
```
