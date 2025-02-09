require 'mysql2'

# Establish a database connection
def get_database_connection
  Mysql2::Client.new(
    host: 'localhost',     # Host where MySQL is running
    username: 'root',      # MySQL username
    password: '',          # MySQL password
    database: 'tax_calculator' # Database name
  )
end

# Preventing SQL injection with prepared statements, in case system expands to use frontend, or other possible threats
def get_product_type(connection, sale_id)
    query = <<-SQL
    SELECT pt.name AS product_type
    FROM sold_items si
    JOIN products p ON si.product_id = p.id
    JOIN product_types pt ON p.product_type_id = pt.id
    WHERE si.sale_id = ?
  SQL
  statement = connection.prepare(query)
  result = statement.execute(sale_id).first
  
  end

  def get_buyer_country_and_type(connection, buyer_id)
    query = <<-SQL
    SELECT c.name AS country_name, c.vat_applicable, c.vat_rate, b.is_company
    FROM buyers b
    JOIN countries c ON b.country_id = c.id
    WHERE b.id = ?
    SQL
    statement = connection.prepare(query)
    result = statement.execute(buyer_id).first # Returns the country name, VAT applicable status, VAT rate, and buyer type
end

  # Get sale amount from sold items and calculate total sale
def get_total_sales_amount(connection, sale_id)
    
    query = <<-SQL
    SELECT si.quantity, p.price_in_euros
    FROM sold_items si
    JOIN products p ON si.product_id = p.id
    WHERE si.sale_id = ?
    SQL
    statement = connection.prepare(query)
    sales = statement.execute(sale_id)
  
    total_amount = 0.0
    sales.each do |item|
      total_amount += item['quantity'].to_f * item['price_in_euros'].to_f
    end
  
    total_amount
  end

  def update_sale(connection, sale_id, subtotal, total_amount, calculated_tax, vat_status)
    
    query = <<-SQL
    UPDATE sales
     SET subtotal = ?, total_amount = ?, calculated_tax = ?, vat_status = ?, processed = ?
     WHERE id = ?
    SQL
    statement = connection.prepare(query)
    statement.execute(subtotal, total_amount, calculated_tax, vat_status, true, sale_id)

  end
  

  
def calculate_eu_tax(connection, sale, vat_rate, is_company)

    if !is_company
         process_tax(connection,sale,vat_rate, "Local eu tax")
    else
        mark_transaction_when_no_tax(connection, sale, "reverse_charge")

  end

end

def mark_transaction_when_no_tax(connection, sale, transaction_marker)

    sale_amount = get_total_sales_amount(connection, sale["id"])
    vat_status = transaction_marker
    total_amount = sale_amount
    calculated_tax = 0
    update_sale(connection, sale["id"],sale_amount, total_amount, calculated_tax, vat_status)


end

def process_tax(connection, sale, vat_rate, transaction_marker)

     vat_status = transaction_marker
    sale_amount = get_total_sales_amount(connection, sale["id"])
    calculated_tax = sale_amount * (vat_rate.to_f / 100)
    total_amount = sale_amount + calculated_tax
    update_sale(connection, sale["id"],sale_amount, total_amount, calculated_tax, vat_status)
end

def handle_tax_for_product_type(connection, sale, product_type, vat_applicable, vat_rate, is_company)
    case product_type
    when "good"
      handle_good_sale(connection, sale, vat_applicable, vat_rate, is_company)
    when "digital"
      handle_digital_sale(connection, sale, vat_applicable, vat_rate, is_company)
    when "onsite"
      handle_onsite_sale(connection, sale, vat_applicable, vat_rate)
    else
      puts "Unknown product type: #{product_type}"
    end
  end
  
  def handle_good_sale(connection, sale, vat_applicable, vat_rate, is_company)
    case vat_applicable
    when "spain"
      process_tax(connection, sale, vat_rate, "Spanish VAT")
    when "eu"
      calculate_eu_tax(connection, sale, vat_rate, is_company)
    when "non_eu"
      mark_transaction_when_no_tax(connection, sale, "export")
    end
  end
  
  def handle_digital_sale(connection, sale, vat_applicable, vat_rate, is_company)
    case vat_applicable
    when "spain"
      process_tax(connection, sale, vat_rate, "Spanish VAT")
    when "eu"
      calculate_eu_tax(connection, sale, vat_rate, is_company)
    when "non_eu"
      mark_transaction_when_no_tax(connection, sale, "no tax applied")
    end
  end
  
  def handle_onsite_sale(connection, sale, vat_applicable, vat_rate)
    case vat_applicable
    when "spain"
      process_tax(connection, sale, vat_rate, "Spanish VAT")
    when "eu", "non_eu"
      process_tax(connection, sale, vat_rate, "Local tax")
    end
  end
  

def calculate_tax
 
  connection = get_database_connection

  begin
   
    sales = connection.query("SELECT * FROM sales")

  
    sales.each do |sale|

        # Skip calculation if the sale has already been processed (processed = true)
      next if sale['processed'] == 1
    
     
      product_type = get_product_type(connection, sale['id'])
      buyer_info = get_buyer_country_and_type(connection,sale["buyer_id"])   
      is_company = buyer_info["is_company"] == 1
      vat_applicable = buyer_info["vat_applicable"]
      vat_rate = buyer_info["vat_rate"]

      handle_tax_for_product_type(connection, sale, product_type["product_type"], vat_applicable, vat_rate, is_company)

     
   
    end
  rescue Mysql2::Error => e
    puts "Error: #{e.message}"
  ensure
    connection.close if connection
  end
end

# Run the tax calculation function
calculate_tax


