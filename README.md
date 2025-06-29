# Cash Register API 🛒

A Ruby on Rails 8 API backend for a cash register system with product management, cart functionality, and product promotion engine.

[![Ruby Version](https://img.shields.io/badge/ruby-3.4.2-red.svg)](https://www.ruby-lang.org)
[![Rails Version](https://img.shields.io/badge/rails-8.0.2-red.svg)](https://rubyonrails.org)
[![Test Coverage](https://img.shields.io/badge/coverage-90%25+-brightgreen.svg)](rspec)
[![Code Quality](https://img.shields.io/badge/rubocop-passing-brightgreen.svg)](rubocop)

## 🚀 Features

### ✨ Live Demo

The codebase was already deployed to an AWS EC2 t2.large instance with:

- Ubuntu 24.04 LTS
- PostgreSQL 16
- Puma web server reverse-proxied by Nginx

`curl` can be used to interact with the API endpoints like:

```bash
curl -X GET http://54.169.235.10/api/v1/products
```

Unfortunately, only http/80 can be used since I don't have a domain name thus SSL cert is not available.

Or you can use the frontend app to interact with the API. here's the link: https://d3vvbb4sx6mq4p.cloudfront.net

The SPA was built using React + TypeScript + Vite.

The frontend app is deployed to a CloudFront distribution with an S3 bucket as the origin.
The CF distribution together with a Lambda@Edge function was used as a workaround for the lack of SSL certificate in the backend API.
See the github repo for the frontend app: https://github.com/kanutocd/cash_register_spa

### 🛍️ **Product Management**

- **CRUD Operations**: Create, read, update, and soft-delete products
- **Product Validation**: Comprehensive validation for code, names, prices, and descriptions
- **Active Status**: Enable/disable products without data loss
- **Rich Metadata**: Store detailed product information

### 🎯 **Advanced Promotion System**

Support for three distinct promotion types:

1. **Buy X Get Y Free**: `buy_x_get_y_free`

   - Example: Buy 2 apples, get 1 free

2. **Percentage Discount**: `percentage_discount`

   - Example: 15% off when buying 3 or more items

3. **Fixed Amount Discount**: `fixed_discount`
   - Example: $2 off each item when buying 5 or more

### 🛒 **Smart Cart Management**

- **Real-time Calculations**: Automatic price and discount computation
- **Quantity Management**: Add, update, remove items seamlessly
- **Promotion Application**: Intelligent discount application based on quantity
- **Cart Totals**: Detailed breakdown of subtotals, discounts, and finals

### 🔒 **Enterprise-Ready**

- **RESTful API**: Clean, predictable endpoints following REST conventions
- **CORS Support**: Configured for cross-origin requests
- **Error Handling**: Comprehensive error responses with detailed messages
- **Test Coverage**: 90%+ test coverage with RSpec and FactoryBot

## 📋 Prerequisites

- **Ruby**: 3.4.2 or higher
- **Rails**: 8.0.2 or higher
- **PostgreSQL**: THE Database for production and development
- **Bundler**: For dependency management

## 🛠️ Installation

### 1. Clone the Repository

```bash
git clone https://github.com/kanutocd/cash_register_api.git
cd cash_register_api
```

### 2. Install Dependencies

```bash
bundle install
```

### 3. Database Setup

```bash
# Create and migrate database
rails db:create
rails db:migrate

# Seed with sample data
rails db:seed
```

### 4. Start the Server

```bash
rails server
```

The API will be available at `http://localhost:3000`

## 🧪 Testing

### Run All Tests

```bash
# Run the full test suite
bundle exec rspec

# Run with coverage report
bundle exec rspec --format documentation
```

### Test Coverage

```bash
# Generate coverage report
COVERAGE=true bundle exec rspec
open coverage/index.html
```

### Code Quality

```bash
# Run RuboCop for code style
bundle exec rubocop

# Auto-fix violations
bundle exec rubocop -A
```

## 📖 API Documentation

### Base URL

```
http://localhost:3000/api/v1
```

### 🛍️ Products Endpoints

#### Get All Products

```http
GET /products
```

**Response:**

```json
[
  {
    "id": 1,
    "name": "Apple",
    "description": "Fresh red apples",
    "price": 1.5,
    "active": true,
    "promotions": [
      {
        "id": 1,
        "name": "Buy 2 Get 1 Free",
        "promotion_type": "buy_x_get_y_free",
        "trigger_quantity": 2,
        "free_quantity": 1,
        "active": true
      }
    ]
  }
]
```

#### Create Product

```http
POST /products
Content-Type: application/json

{
  "product": {
    "name": "Orange",
    "description": "Fresh citrus oranges",
    "price": 2.00,
    "active": true
  }
}
```

#### Update Product

```http
PUT /products/:id
Content-Type: application/json

{
  "product": {
    "name": "Updated Product Name",
    "price": 2.50
  }
}
```

#### Delete Product (Soft Delete)

```http
DELETE /products/:id
```

### 🎯 Promotions Endpoints

#### Create Promotion

```http
POST /products/:product_id/promotions
Content-Type: application/json

{
  "promotion": {
    "name": "Summer Sale",
    "promotion_type": "percentage_discount",
    "trigger_quantity": 3,
    "discount_percentage": 20.0,
    "active": true
  }
}
```

#### Update Promotion

```http
PUT /products/:product_id/promotions/:id
```

#### Delete Promotion

```http
DELETE /products/:product_id/promotions/:id
```

### 🛒 Cart Endpoints

#### Get Cart Items

```http
GET /cart_items
```

**Response:**

```json
[
  {
    "id": 1,
    "quantity": 2,
    "total_price": 3.0,
    "discount_amount": 0,
    "product": {
      "id": 1,
      "name": "Apple",
      "price": 1.5
    }
  }
]
```

#### Add to Cart

```http
POST /cart_items
Content-Type: application/json

{
  "cart_item": {
    "product_id": 1,
    "quantity": 2
  }
}
```

#### Update Cart Item

```http
PUT /cart_items/:id
Content-Type: application/json

{
  "cart_item": {
    "quantity": 3
  }
}
```

#### Remove from Cart

```http
DELETE /cart_items/:id
```

#### Clear Cart

```http
DELETE /cart
```

#### Get Cart Total

```http
GET /cart/total
```

**Response:**

```json
{
  "subtotal": 25.5,
  "total_discount": 3.75,
  "total": 21.75,
  "items_count": 8
}
```

## 🏗️ Architecture

### Models

#### Product Model

```ruby
class Product < ApplicationRecord
  has_many :promotions, dependent: :destroy
  has_many :cart_items, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true

  scope :active, -> { where(active: true) }
end
```

#### Promotion Model

```ruby
class Promotion < ApplicationRecord
  belongs_to :product

  validates :promotion_type, inclusion: {
    in: %w[buy_x_get_y_free percentage_discount fixed_discount]
  }

  def apply_discount(quantity, unit_price)
    # Complex discount calculation logic
  end
end
```

#### Cart Item Model

```ruby
class CartItem < ApplicationRecord
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :product_id, uniqueness: true

  def total_price
    # Price calculation with promotion logic
  end
end
```

### Controllers

Controllers follow RESTful conventions with proper error handling:

```ruby
class Api::V1::ProductsController < ApplicationController
  before_action :set_product, only: [:show, :update, :destroy]

  def index
    @products = Product.active.includes(:promotions)
    render json: @products.as_json(include: :promotions)
  end

  private

  def product_params
    params.require(:product).permit(:name, :description, :price, :active)
  end
end
```

## 🧪 Testing Strategy

### RSpec Configuration

- **Model Tests**: Comprehensive validation and association testing
- **Controller Tests**: API endpoint testing with various scenarios
- **Factory Bot**: Clean test data generation
- **Database Cleaner**: Isolated test environment

### Sample Test

```ruby
RSpec.describe Product, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_numericality_of(:price).is_greater_than(0) }
  end

  describe '#current_promotion' do
    let(:product) { create(:product) }
    let!(:active_promotion) { create(:promotion, product: product, active: true) }

    it 'returns the first active promotion' do
      expect(product.current_promotion).to eq(active_promotion)
    end
  end
end
```

## 🚀 Deployment

### Environment Variables

```bash
# .env (create from .env.example)
RAILS_ENV=production
DATABASE_URL=postgresql://user:pass@localhost/myapp_production
SECRET_KEY_BASE=your_secret_key
CORS_ORIGINS=https://yourfrontend.com
```

### Production Setup

```bash
# Precompile assets (if any)
RAILS_ENV=production rails assets:precompile

# Run migrations
RAILS_ENV=production rails db:migrate

# Start server
RAILS_ENV=production rails server -p 3000
```

## 🔧 Configuration

### CORS Configuration

```ruby
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # Configure for production
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

## 📊 Performance Considerations

### Database Optimization

- **Indexes**: Proper indexing on frequently queried columns
- **Includes**: Prevent N+1 queries with eager loading
- **Scopes**: Efficient query scopes for common filters

### Input Validation

- **Strong Parameters**: Whitelist permitted parameters
- **Model Validations**: Comprehensive validation rules
- **SQL Injection Prevention**: Parameterized queries only

### API Security

```ruby
# Rate limiting (add gem 'rack-attack')
class Rack::Attack
  throttle('api/ip', limit: 300, period: 5.minutes) do |req|
    req.ip if req.path.start_with?('/api/')
  end
end
```

---

**Built with ❤️ using Ruby on Rails 8.0.2**
