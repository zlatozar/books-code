﻿module internal OrderTaking.PlaceOrder.ImplementationWithoutEffects

// version 1 (simplified)
open OrderTaking.Common

// This file contains the implementation for the PlaceOrder workflow
// WITHOUT any effects like Result or Async.
//
// This represents the code in chapter 9, "Composing a Pipeline"
//
// There are two parts:
// * the first section contains the (type-only) definitions for each step
// * the second section contains the implementations for each step
//   and the implementation of the overall workflow

// ======================================================
// ATTENTION! Implementation is simplified:
//            Override the SimpleType constructors so that
//            they raise exceptions rather than return Results
// ======================================================

//_____________________________________________________________________________
//                                                              Simplification

/// Helper to convert Results into exceptions so we can reuse the smart constructors in SimpleTypes
let failOnError aResult =
    match aResult with
    | Ok success  -> success 
    | Error error -> failwithf "%A" error

module String50 =
    let create fieldName = String50.create fieldName >> failOnError
    let createOption fieldName = String50.createOption fieldName >> failOnError

module EmailAddress =
    let create fieldName = EmailAddress.create fieldName >> failOnError

module ZipCode =
    let create fieldName = ZipCode.create fieldName >> failOnError

module OrderId =
    let create fieldName = OrderId.create fieldName >> failOnError

module OrderLineId =
    let create fieldName = OrderLineId.create fieldName >> failOnError

module WidgetCode =
    let create fieldName = WidgetCode.create fieldName >> failOnError

module GizmoCode =
    let create fieldName = GizmoCode.create fieldName >> failOnError

module ProductCode =
    let create fieldName = ProductCode.create fieldName >> failOnError

module UnitQuantity  =
    let create fieldName = UnitQuantity.create fieldName >> failOnError

module KilogramQuantity =
    let create fieldName = KilogramQuantity.create fieldName >> failOnError

module OrderQuantity  =
    let create fieldName productCode = OrderQuantity.create fieldName productCode >> failOnError

module Price =
    let create = Price.create >> failOnError
    let multiply qty price = Price.multiply qty price |> failOnError

module BillingAmount =
    let create = BillingAmount.create >> failOnError
    let sumPrices = BillingAmount.sumPrices >> failOnError

// ======================================================
// Section 1 : Define each step in the workflow using just types
// ======================================================

//_____________________________________________________________________________
//                 Types                                   1.1 Validation step

// 1.1.1 Product validation

type CheckProductCodeExists = 
    ProductCode -> bool

// 1.1.2 Address validation exception
exception AddressValidationFailure of string

type CheckedAddress = CheckedAddress of UnvalidatedAddress

type CheckAddressExists = 
    UnvalidatedAddress -> CheckedAddress

// 1.1.3 Validated Order 

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
    }

// 1.1.3 Implemetation

type ValidateOrder = 
    CheckProductCodeExists  // dependency
      -> CheckAddressExists // dependency
      -> UnvalidatedOrder   // input
      -> ValidatedOrder     // output

//_____________________________________________________________________________
//                 Types                                      1.2 Pricing step

type GetProductPrice = 
    ProductCode -> Price

// Implemetation

type PriceOrder = 
    GetProductPrice     // dependency
      -> ValidatedOrder // input
      -> PricedOrder    // output

//_____________________________________________________________________________
//                 Types                          1.3 Send OrderAcknowledgment 

type HtmlString = 
    HtmlString of string

type OrderAcknowledgment = {
    EmailAddress : EmailAddress
    Letter : HtmlString 
    }

// Implemetation

type CreateOrderAcknowledgmentLetter =
    PricedOrder -> HtmlString

//_____________________________________________________________________________
//                 Types    1.4 Send the order acknowledgement to the customer

/// Send the order acknowledgement to the customer
/// Note that this does NOT generate an Result-type error (at least not in this workflow)
/// because on failure we will continue anyway. On success, we will generate
/// a OrderAcknowledgmentSent event, but on failure we won't.
type SendResult = Sent | NotSent

type SendOrderAcknowledgment =
    OrderAcknowledgment -> SendResult 
    
// Implemetation

type AcknowledgeOrder = 
    CreateOrderAcknowledgmentLetter  // dependency
     -> SendOrderAcknowledgment      // dependency
     -> PricedOrder                    // input
     -> OrderAcknowledgmentSent option // output

//_____________________________________________________________________________
//                 Types                                     1.5 Create events

// Implemetation

type CreateEvents = 
    PricedOrder                           // input
     -> OrderAcknowledgmentSent option    // input (event from previous step)
     -> PlaceOrderEvent list              // output

// ======================================================
// Section 2 : Implementation of dependencies
// ======================================================

//_____________________________________________________________________________
//                 Imlementation                        2.1 ValidateOrder step

let toCustomerInfo (unvalidatedCustomerInfo: UnvalidatedCustomerInfo) =
    let firstName = 
        unvalidatedCustomerInfo.FirstName
            |> String50.create "FirstName"
    let lastName = 
        unvalidatedCustomerInfo.LastName
            |> String50.create "LastName"
    let emailAddress = 
        unvalidatedCustomerInfo.EmailAddress
            |> EmailAddress.create "EmailAddress"
    let customerInfo = {
        Name = {FirstName=firstName; LastName=lastName}
        EmailAddress = emailAddress
        }
    customerInfo 

let toAddress (checkAddressExists: CheckAddressExists) unvalidatedAddress =
    // call the remote service
    let checkedAddress = checkAddressExists unvalidatedAddress 
    // extract the inner value using pattern matching
    let (CheckedAddress checkedAddress) = checkedAddress 

    let addressLine1 = 
        checkedAddress.AddressLine1 
            |> String50.create "AddressLine1" 
    let addressLine2 = 
        checkedAddress.AddressLine2 
            |> String50.createOption "AddressLine2" 
    let addressLine3 = 
        checkedAddress.AddressLine3 
            |> String50.createOption "AddressLine3"
    let addressLine4 = 
        checkedAddress.AddressLine4 
            |> String50.createOption "AddressLine4"
    let city = 
        checkedAddress.City
            |> String50.create "City"
    let zipCode = 
        checkedAddress.ZipCode
            |> ZipCode.create "ZipCode"
    let address : Address = {
        AddressLine1 = addressLine1
        AddressLine2 = addressLine2
        AddressLine3 = addressLine3
        AddressLine4 = addressLine4
        City = city
        ZipCode = zipCode
        }
    address

/// Function adapter to convert a predicate to a passthru 
let predicateToPassthru errorMsg f x =
    if f x then
        x
    else
        failwith errorMsg

/// Helper function for validateOrder   
let toProductCode (checkProductCodeExists: CheckProductCodeExists) productCode = 
    // create a ProductCode -> ProductCode function 
    // suitable for using in a pipeline
    let checkProduct productCode = 
        let errorMsg = sprintf "Invalid: %A" productCode 
        predicateToPassthru errorMsg checkProductCodeExists productCode
    // assemble the pipeline        
    productCode
        |> ProductCode.create "ProductCode"
        |> checkProduct 

/// Helper function for validateOrder   
let toValidatedOrderLine checkProductExists (unvalidatedOrderLine: UnvalidatedOrderLine) = 
    let orderLineId = 
        unvalidatedOrderLine.OrderLineId 
            |> OrderLineId.create "OrderLineId" 
    let productCode = 
        unvalidatedOrderLine.ProductCode 
            |> toProductCode checkProductExists
    let quantity = 
        unvalidatedOrderLine.Quantity 
            |> OrderQuantity.create "OrderQuantity" productCode 
    let validatedOrderLine = {
        OrderLineId = orderLineId 
        ProductCode = productCode 
        Quantity = quantity 
        }
    validatedOrderLine 

let validateOrder :ValidateOrder = 
    fun checkProductCodeExists checkAddressExists unvalidatedOrder ->
        let orderId = 
            unvalidatedOrder.OrderId 
                |> OrderId.create "OrderId" 
        let customerInfo = 
            unvalidatedOrder.CustomerInfo 
                |> toCustomerInfo
        let shippingAddress = 
            unvalidatedOrder.ShippingAddress 
                |> toAddress checkAddressExists
        let billingAddress  = 
            unvalidatedOrder.BillingAddress 
                |> toAddress checkAddressExists
        let lines = 
            unvalidatedOrder.Lines 
                |> List.map (toValidatedOrderLine checkProductCodeExists) 
        let validatedOrder : ValidatedOrder = {
            OrderId  = orderId 
            CustomerInfo = customerInfo 
            ShippingAddress = shippingAddress 
            BillingAddress = billingAddress  
            Lines = lines 
        }
        validatedOrder 

//_____________________________________________________________________________
//                 Imlementation                           2.2 PriceOrder step

let toPricedOrderLine (getProductPrice:GetProductPrice) (validatedOrderLine:ValidatedOrderLine) = 
    let qty = validatedOrderLine.Quantity |> OrderQuantity.value 
    let price = validatedOrderLine.ProductCode |> getProductPrice 
    let linePrice = price |> Price.multiply qty 
    let pricedLine : PricedOrderLine = {
        OrderLineId = validatedOrderLine.OrderLineId 
        ProductCode = validatedOrderLine.ProductCode 
        Quantity = validatedOrderLine.Quantity
        LinePrice = linePrice
        }
    pricedLine

let priceOrder :PriceOrder = 
    fun getProductPrice validatedOrder ->
        let lines = 
            validatedOrder.Lines 
                |> List.map (toPricedOrderLine getProductPrice) 
        let amountToBill = 
            lines 
                |> List.map (fun line -> line.LinePrice)  // get each line price
                |> BillingAmount.sumPrices                // add them together as a BillingAmount
        let pricedOrder : PricedOrder = {
            OrderId  = validatedOrder.OrderId 
            CustomerInfo = validatedOrder.CustomerInfo 
            ShippingAddress = validatedOrder.ShippingAddress 
            BillingAddress = validatedOrder.BillingAddress  
            Lines = lines 
            AmountToBill = amountToBill 
            }
        pricedOrder 
        
//_____________________________________________________________________________
//                 Imlementation                     2.3 AcknowledgeOrder step

let acknowledgeOrder :AcknowledgeOrder = 
    fun createAcknowledgmentLetter sendAcknowledgment pricedOrder ->
        let letter = createAcknowledgmentLetter pricedOrder
        let acknowledgment = {
            EmailAddress = pricedOrder.CustomerInfo.EmailAddress
            Letter = letter 
            }
        // if the acknowledgement was successfully sent,
        // return the corresponding event, else return None
        match sendAcknowledgment acknowledgment with
        | Sent    -> 
            let event = {
                OrderId = pricedOrder.OrderId
                EmailAddress = pricedOrder.CustomerInfo.EmailAddress
                } 
            Some event
        | NotSent ->
            None

//_____________________________________________________________________________
//                 Imlementation                             2.4 Create events

let createOrderPlacedEvent (placedOrder: PricedOrder) =
    placedOrder

let createBillingEvent (placedOrder: PricedOrder) :BillableOrderPlaced option =
    let billingAmount = placedOrder.AmountToBill |> BillingAmount.value
    if billingAmount > 0M then
        {
        OrderId = placedOrder.OrderId
        BillingAddress = placedOrder.BillingAddress
        AmountToBill = placedOrder.AmountToBill 
        } |> Some
    else
        None

/// Helper to convert an Option into a List
let listOfOption opt =
    match opt with 
    | Some x -> [x]
    | None   -> []

let createEvents :CreateEvents = 
    fun pricedOrder acknowledgmentEventOpt ->
        let acknowledgmentEvents = 
            acknowledgmentEventOpt 
                |> Option.map PlaceOrderEvent.AcknowledgmentSent
                |> listOfOption
        let orderPlacedEvents = 
            pricedOrder
                |> createOrderPlacedEvent
                |> PlaceOrderEvent.OrderPlaced
                |> List.singleton
        let billingEvents = 
            pricedOrder
                |> createBillingEvent 
                |> Option.map PlaceOrderEvent.BillableOrderPlaced
                |> listOfOption

        // return all the events
        [
        yield! acknowledgmentEvents
        yield! orderPlacedEvents 
        yield! billingEvents
        ]            

// ======================================================
// Overall workflow implementation
// ======================================================

type PlaceOrderWithoutEffects = 
    UnvalidatedOrder -> PlaceOrderEvent list
    
let placeOrder 
    checkProductExists // dependency
    checkAddressExists // dependency
    getProductPrice    // dependency
    createOrderAcknowledgmentLetter  // dependency
    sendOrderAcknowledgment          // dependency
    :PlaceOrderWithoutEffects =      // definition of function

    fun unvalidatedOrder -> 
        let validatedOrder = 
            unvalidatedOrder 
                |> validateOrder checkProductExists checkAddressExists 
        let pricedOrder = 
            validatedOrder 
                |> priceOrder getProductPrice 
        let acknowledgementOption = 
            pricedOrder 
                |> acknowledgeOrder createOrderAcknowledgmentLetter sendOrderAcknowledgment 
        let events = 
            createEvents pricedOrder acknowledgementOption 
        events
