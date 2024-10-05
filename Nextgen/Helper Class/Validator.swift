//
//  Validator.swift
//  GoodLifeApplocation
//
//  Created by heba isaa on 01/09/2022.
//

import Foundation

import UIKit.UITextField

class ValidationError: Error {
   var message: String
   
   init(_ message: String) {
       self.message = message
   }
}

protocol ValidatorConvertible {
   func validated(_ value: String) throws -> String
}

enum ValidatorType {
   case email
   case password
   case username
   case projectIdentifier
   case requiredField(field: String)
   case age
   case phoneNumber
}

enum ValidatorFactory {
   static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
       switch type {
       case .email: return EmailValidator()
       case .password: return PasswordValidator()
       case .username: return UserNameValidator()
       case .projectIdentifier: return ProjectIdentifierValidator()
       case .requiredField(let fieldName): return RequiredFieldValidator(fieldName)
       case .age: return AgeValidator()
       case .phoneNumber:
           return PhoneValidator()        }
   }
}

//"J3-123A" i.e
struct ProjectIdentifierValidator: ValidatorConvertible {
   func validated(_ value: String) throws -> String {
       do {
           if try NSRegularExpression(pattern: "^[A-Z]{1}[0-9]{1}[-]{1}[0-9]{3}[A-Z]$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
               throw ValidationError("Invalid Project Identifier Format")
           }
       } catch {
           throw ValidationError("Invalid Project Identifier Format")
       }
       return value
   }
}


class AgeValidator: ValidatorConvertible {
   func validated(_ value: String) throws -> String {
       guard value.count > 0 else {throw ValidationError("Age is required")}
       guard let age = Int(value) else {throw ValidationError("Age must be a number!")}
       guard value.count < 3 else {throw ValidationError("Invalid age number!")}
       guard age >= 18 else {throw ValidationError("You have to be over 18 years old to user our app :)")}
       return value
   }
}

struct RequiredFieldValidator: ValidatorConvertible {
   private let fieldName: String
   
   init(_ field: String) {
       fieldName = field
   }
   
   func validated(_ value: String) throws -> String {
       guard !value.isEmpty else {
           throw ValidationError(fieldName)
       }
       return value
   }
}

struct UserNameValidator: ValidatorConvertible {
   func validated(_ value: String) throws -> String {
       guard value.count >= 3 else {
           throw ValidationError("Username must contain more than three characters" )
       }
       guard value.count < 18 else {
           throw ValidationError("Username shoudn't conain more than 18 characters" )
       }
       
       do {
           if try NSRegularExpression(pattern: "^[a-z]{1,18}$",  options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
               throw ValidationError("Invalid username, username should not contain whitespaces, numbers or special characters")
           }
       } catch {
           throw ValidationError("Invalid username, username should not contain whitespaces,  or special characters")
       }
       return value
   }
}

struct PasswordValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else {
            throw ValidationError("Password is required")
        }
        guard value.count >= 6 else {
            throw ValidationError("Password must have at least 6 characters")
        }
        
        do {
            if try NSRegularExpression(pattern: "^(?:(?=.?[0-9])(?=.?[-!@#$%&ˆ+=_])(?=.?[A-Za-z]))[A-Za-z0-9-!@#$%&*ˆ+=_]{6,}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Password must have  uppercase letter, lowercase letter, digit, and  special character")
            }
        } catch {
            throw ValidationError("Password must have at least one uppercase letter, one lowercase letter, one digit, and one special character")
        }
        return value
    }
}


struct PhoneValidator: ValidatorConvertible {
   func validate(value: String) -> Bool {
              let PHONE_REGEX = "^\\d{3}\\d{3}\\d{4}$"
              let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
              let result = phoneTest.evaluate(with: value)
              return result
   }
   
   func validated(_ value: String) throws -> String {
       do {
           
           
           if !self.validate(value: value){
               throw ValidationError("Invalid Phone number")
           }
       } catch {
           throw ValidationError("Invalid Phone number")
       }
       return value
   }
}



struct EmailValidator: ValidatorConvertible {
   func validated(_ value: String) throws -> String {
       do {
           if try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
               throw ValidationError("Invalid e-mail Address")
           }
       } catch {
           throw ValidationError("Invalid e-mail Address")
       }
       return value
   }
}

extension UITextField {
   func validatedText(validationType: ValidatorType) throws -> String {
       let validator = ValidatorFactory.validatorFor(type: validationType)
       return try validator.validated(self.text!)
   }
}
extension String {
   func validatedText(validationType: ValidatorType) throws -> String {
       let validator = ValidatorFactory.validatorFor(type: validationType)
       return try validator.validated(self)
   }
}
