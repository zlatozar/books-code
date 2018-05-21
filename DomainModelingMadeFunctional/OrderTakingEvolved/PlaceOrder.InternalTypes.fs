// Note that this module is internal
module internal OrderTaking.PlaceOrder.InternalTypes

open OrderTaking.Common

// NEW

// ======================================================
// Define each step in the PlaceOrder workflow using internal types 
// (not exposed outside the bounded context)
// ======================================================

//_________________________________________________________________________
//             Types                                 1. Validatаte Address

// 1.1 Product validation

type CheckProductCodeExists = 
    ProductCode -> bool

// 1.2 Address validation

type AddressValidationError = 
    | InvalidFormat 
    | AddressNotFound 

type CheckedAddress = CheckedAddress of UnvalidatedAddress

// 1.3 Implemenation

type CheckAddressExists = 
    UnvalidatedAddress -> AsyncResult<CheckedAddress,AddressValidationError>

//_________________________________________________________________________
//             Types                                    2. Validated Order 

type PricingMethod =
    | Standard
    | Promotion of PromotionCode 

type ValidatedOrderLine =  {
    OrderLineId : OrderLineId 
    ProductCode : ProductCode 
    Quantity : OrderQuantity
    }

type ValidatedOrder = {
    OrderId : OrderId
    CustomerInfo : CustomerInfo
    ShippingAddress : Address
    BillingAddress : Address
    Lines : ValidatedOrderLine list
    PricingMethod : PricingMethod
    }

// Implementation

type ValidateOrder = 
    CheckProductCodeExists  // dependency
     -> CheckAddressExists  // dependency
     -> UnvalidatedOrder    // input
     -> AsyncResult<ValidatedOrder, ValidationError> // output

//_________________________________________________________________________
//             Types                                       3. Pricing step

type GetProductPrice = 
    ProductCode -> Price

type TryGetProductPrice = 
    ProductCode -> Price option

type GetPricingFunction = PricingMethod -> GetProductPrice

type GetStandardPrices = 
    // no input -> return standard prices
    unit -> GetProductPrice

type GetPromotionPrices = 
    // promo input -> return prices for promo, maybe
    PromotionCode -> TryGetProductPrice 

// Priced state     
       
type PricedOrderProductLine = {
    OrderLineId : OrderLineId 
    ProductCode : ProductCode 
    Quantity : OrderQuantity
    LinePrice : Price
    }

type PricedOrderLine = 
    | ProductLine of PricedOrderProductLine
    | CommentLine of string

type PricedOrder = {
    OrderId : OrderId
    CustomerInfo : CustomerInfo
    ShippingAddress : Address
    BillingAddress : Address
    AmountToBill : BillingAmount
    Lines : PricedOrderLine list
    PricingMethod : PricingMethod
    }

// Implementation

type PriceOrder = 
    GetPricingFunction  // dependency
     -> ValidatedOrder  // input
     -> Result<PricedOrder, PricingError>  // output

//_________________________________________________________________________
//             Types                                           4. Shipping

type ShippingMethod = 
    | PostalService 
    | Fedex24 
    | Fedex48 
    | Ups48

type ShippingInfo = {
    ShippingMethod : ShippingMethod
    ShippingCost : Price
    }

type PricedOrderWithShippingMethod = {
    ShippingInfo : ShippingInfo 
    PricedOrder : PricedOrder
    }

type CalculateShippingCost = 
    PricedOrder -> Price

// Implementation

type AddShippingInfoToOrder = 
    CalculateShippingCost // dependency
     -> PricedOrder       // input
     -> PricedOrderWithShippingMethod  // output

//_________________________________________________________________________
//             Types (new)                                 5. VIP shipping

// Implemetation

type FreeVipShipping =
    PricedOrderWithShippingMethod -> PricedOrderWithShippingMethod

//_________________________________________________________________________
//             Types                           6. Send OrderAcknowledgment 

type HtmlString = 
    HtmlString of string

type OrderAcknowledgment = {
    EmailAddress : EmailAddress
    Letter : HtmlString 
    }

type CreateOrderAcknowledgmentLetter =
    PricedOrderWithShippingMethod -> HtmlString

/// Send the order acknowledgement to the customer
/// Note that this does NOT generate an Result-type error (at least not in this workflow)
/// because on failure we will continue anyway.
/// On success, we will generate a OrderAcknowledgmentSent event,
/// but on failure we won't.

type SendResult = Sent | NotSent

type SendOrderAcknowledgment =
    OrderAcknowledgment -> SendResult 
    
// Implemetation

type AcknowledgeOrder = 
    CreateOrderAcknowledgmentLetter    // dependency
     -> SendOrderAcknowledgment        // dependency
     -> PricedOrderWithShippingMethod  // input
     -> OrderAcknowledgmentSent option // output

//_________________________________________________________________________
//             Types                                      7. Create events

// Implemetation

type CreateEvents = 
    PricedOrder                         // input
     -> OrderAcknowledgmentSent option  // input (event from previous step)
     -> PlaceOrderEvent list            // output
