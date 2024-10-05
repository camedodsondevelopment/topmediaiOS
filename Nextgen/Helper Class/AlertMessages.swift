//
//  Alert.swift
//  Persell
//
//  Created by Himanshu Visroliya on 14/08/22.
//

import Foundation

struct AlertMessage {
    

    static let  nameMissing: String =  "Please enter your name".localized
    static let  dobMissing: String =  "Please enter your date of birth".localized
    static let  EmailNameMissing: String = "Please enter your email".localized
    static let  ValidEmail: String = "Please enter valid email".localized
    static let  ValidPassword: String = "Please enter valid Password".localized
    static let  PasswordNotMatch: String = "Password doesn't match!".localized
    static let  PasswordMissing: String = "Please enter password".localized
    static let  PasswordMinMissing: String = "Passwords atleast 6 characters".localized
    static let  currentPasswordMissing: String = "Please enter current password".localized
    static let  ConfirmPasswordMissing: String = "Please enter confirm password".localized
    static let  NewpasswordMissing: String = "Please enter new password".localized
    static let  NewPasswordMinMissing: String = "Please enter passwords atleast 6 characters".localized
    static let noDataFound = "No data found!".localized
    static let selectReportReason = "Please select report reason".localized
    static let enterReportDescription = "Please enter report description".localized
    static let unfollowConfirmation = "Are you sure want to unfollow this user?".localized
    static let removeFollowingUser = "Are you sure want to remove this user?".localized
    static let selectIssueReason = "Please select issuet type".localized
    static let enterIssueDescription = "Please enter issue description".localized
    static let helpSentSuccess = "Your help request sent successfully!".localized
    static let monthValidate = "Please enter a valid month value.".localized
    static let dateValidate = "Please enter a valid date value.".localized

}

