package datablocks.dlm.util;

public class EncUtil {

    public static String processData(String piiType, String companyCode, boolean isEncrypt, String data) {
        switch (piiType) {
            case "1_1_driverLicense":
                return isEncrypt ? encryptDriverLicense(companyCode, data) : decryptDriverLicense(companyCode, data);
            case "1_1_governmentID":
                return isEncrypt ? encryptGovernmentID(companyCode, data) : decryptGovernmentID(companyCode, data);
            case "1_1_passport":
                return isEncrypt ? encryptPassport(companyCode, data) : decryptPassport(companyCode, data);
            case "1_1_rrn":
                return isEncrypt ? encryptRRN(companyCode, data) : decryptRRN(companyCode, data);
            case "1_2_beliefs":
                return isEncrypt ? encryptBeliefs(companyCode, data) : decryptBeliefs(companyCode, data);
            case "1_2_criminalHistory":
                return isEncrypt ? encryptCriminalHistory(companyCode, data) : decryptCriminalHistory(companyCode, data);
            case "1_2_geneticInfo":
                return isEncrypt ? encryptGeneticInfo(companyCode, data) : decryptGeneticInfo(companyCode, data);
            case "1_2_health":
                return isEncrypt ? encryptHealth(companyCode, data) : decryptHealth(companyCode, data);
            case "1_2_politicalViews":
                return isEncrypt ? encryptPoliticalViews(companyCode, data) : decryptPoliticalViews(companyCode, data);
            case "1_2_sexualOrientation":
                return isEncrypt ? encryptSexualOrientation(companyCode, data) : decryptSexualOrientation(companyCode, data);
            case "1_2_unionParty":
                return isEncrypt ? encryptUnionParty(companyCode, data) : decryptUnionParty(companyCode, data);
            case "1_3_biometrics":
                return isEncrypt ? encryptBiometrics(companyCode, data) : decryptBiometrics(companyCode, data);
            case "1_3_pwd":
                return isEncrypt ? encryptPassword(companyCode, data) : decryptPassword(companyCode, data);
            case "1_4_account":
                return isEncrypt ? encryptAccount(companyCode, data) : decryptAccount(companyCode, data);
            case "1_4_cardExpiration":
                return isEncrypt ? encryptCardExpiration(companyCode, data) : decryptCardExpiration(companyCode, data);
            case "1_4_cardReplacement":
                return isEncrypt ? encryptCardReplacement(companyCode, data) : decryptCardReplacement(companyCode, data);
            case "1_4_creditCard":
                return isEncrypt ? encryptCreditCard(companyCode, data) : decryptCreditCard(companyCode, data);
            case "1_4_cvv":
                return isEncrypt ? encryptCVV(companyCode, data) : decryptCVV(companyCode, data);
            case "1_5_healthStatus":
                return isEncrypt ? encryptHealthStatus(companyCode, data) : decryptHealthStatus(companyCode, data);
            case "1_5_medicalRecords":
                return isEncrypt ? encryptMedicalRecords(companyCode, data) : decryptMedicalRecords(companyCode, data);
            case "1_6_location":
                return isEncrypt ? encryptLocation(companyCode, data) : decryptLocation(companyCode, data);
            case "2_1_age":
                return isEncrypt ? encryptAge(companyCode, data) : decryptAge(companyCode, data);
            case "2_1_cidi":
                return isEncrypt ? encryptCIDI(companyCode, data) : decryptCIDI(companyCode, data);
            case "2_1_dob":
                return isEncrypt ? encryptDOB(companyCode, data) : decryptDOB(companyCode, data);
            case "2_1_gender":
                return isEncrypt ? encryptGender(companyCode, data) : decryptGender(companyCode, data);
            case "2_1_name":
                return isEncrypt ? encryptName(companyCode, data) : decryptName(companyCode, data);
            case "2_2_address1":
                return isEncrypt ? encryptAddress1(companyCode, data) : decryptAddress1(companyCode, data);
            case "2_2_address2":
                return isEncrypt ? encryptAddress2(companyCode, data) : decryptAddress2(companyCode, data);
            case "2_2_email":
                return isEncrypt ? encryptEmail(companyCode, data) : decryptEmail(companyCode, data);
            case "2_2_telno":
                return isEncrypt ? encryptTelNo(companyCode, data) : decryptTelNo(companyCode, data);
            case "2_2_zipcode":
                return isEncrypt ? encryptZipCode(companyCode, data) : decryptZipCode(companyCode, data);
            case "2_3_education":
                return isEncrypt ? encryptEducation(companyCode, data) : decryptEducation(companyCode, data);
            case "2_3_familyStatus":
                return isEncrypt ? encryptFamilyStatus(companyCode, data) : decryptFamilyStatus(companyCode, data);
            case "2_3_height":
                return isEncrypt ? encryptHeight(companyCode, data) : decryptHeight(companyCode, data);
            case "2_3_hobbies":
                return isEncrypt ? encryptHobbies(companyCode, data) : decryptHobbies(companyCode, data);
            case "2_3_job":
                return isEncrypt ? encryptJob(companyCode, data) : decryptJob(companyCode, data);
            case "2_3_maritalStatus":
                return isEncrypt ? encryptMaritalStatus(companyCode, data) : decryptMaritalStatus(companyCode, data);
            case "2_3_photo":
                return isEncrypt ? encryptPhoto(companyCode, data) : decryptPhoto(companyCode, data);
            case "2_3_weight":
                return isEncrypt ? encryptWeight(companyCode, data) : decryptWeight(companyCode, data);
            case "3_1_cookies":
                return isEncrypt ? encryptCookies(companyCode, data) : decryptCookies(companyCode, data);
            case "3_1_imei":
                return isEncrypt ? encryptIMEI(companyCode, data) : decryptIMEI(companyCode, data);
            case "3_1_ipAddress":
                return isEncrypt ? encryptIPAddress(companyCode, data) : decryptIPAddress(companyCode, data);
            case "3_1_macAddress":
                return isEncrypt ? encryptMACAddress(companyCode, data) : decryptMACAddress(companyCode, data);
            case "3_1_usim":
                return isEncrypt ? encryptUSIM(companyCode, data) : decryptUSIM(companyCode, data);
            case "3_1_uuid":
                return isEncrypt ? encryptUUID(companyCode, data) : decryptUUID(companyCode, data);
            case "3_1_websiteHistory":
                return isEncrypt ? encryptWebsiteHistory(companyCode, data) : decryptWebsiteHistory(companyCode, data);
            case "3_2_membershipInfo":
                return isEncrypt ? encryptMembershipInfo(companyCode, data) : decryptMembershipInfo(companyCode, data);
            case "3_2_statistics":
                return isEncrypt ? encryptStatistics(companyCode, data) : decryptStatistics(companyCode, data);
            case "3_3_corpno":
                return isEncrypt ? encryptCorpNo(companyCode, data) : decryptCorpNo(companyCode, data);
            case "3_3_employeeID":
                return isEncrypt ? encryptEmployeeID(companyCode, data) : decryptEmployeeID(companyCode, data);
            case "3_3_internalID":
                return isEncrypt ? encryptInternalID(companyCode, data) : decryptInternalID(companyCode, data);
            case "3_3_memberID":
                return isEncrypt ? encryptMemberID(companyCode, data) : decryptMemberID(companyCode, data);
            default:
                throw new IllegalArgumentException("Unknown PII type: " + piiType);
        }
    }


    private static String encryptDriverLicense(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptDriverLicense(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptGovernmentID(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptGovernmentID(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptPassport(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptPassport(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptRRN(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptRRN(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptBeliefs(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptBeliefs(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptCriminalHistory(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptCriminalHistory(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptGeneticInfo(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptGeneticInfo(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptHealth(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptHealth(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptPoliticalViews(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptPoliticalViews(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptSexualOrientation(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptSexualOrientation(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptUnionParty(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptUnionParty(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptBiometrics(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptBiometrics(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptPassword(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptPassword(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptAccount(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptAccount(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptCardExpiration(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptCardExpiration(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptCardReplacement(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptCardReplacement(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptCreditCard(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptCreditCard(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptCVV(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptCVV(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptHealthStatus(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptHealthStatus(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptMedicalRecords(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptMedicalRecords(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptLocation(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptLocation(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptAge(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptAge(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptCIDI(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptCIDI(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptDOB(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptDOB(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptGender(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptGender(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptName(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptName(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptAddress1(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptAddress1(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptAddress2(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptAddress2(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptEmail(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptEmail(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptTelNo(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptTelNo(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptZipCode(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptZipCode(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptEducation(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptEducation(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptFamilyStatus(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptFamilyStatus(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptHeight(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptHeight(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptHobbies(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptHobbies(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptJob(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptJob(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptMaritalStatus(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptMaritalStatus(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptPhoto(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptPhoto(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptWeight(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptWeight(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptCookies(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptCookies(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptIMEI(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptIMEI(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptIPAddress(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptIPAddress(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptMACAddress(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptMACAddress(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptUSIM(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptUSIM(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptUUID(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptUUID(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptWebsiteHistory(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptWebsiteHistory(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptMembershipInfo(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptMembershipInfo(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptStatistics(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptStatistics(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptCorpNo(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptCorpNo(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptEmployeeID(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptEmployeeID(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptInternalID(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptInternalID(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String encryptMemberID(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

    private static String decryptMemberID(String companyCode, String data) {
        switch (companyCode) {
            case "LOTTECARD": return "A_encrypted_" + data;
            case "OKBANK": return "B_encrypted_" + data;
            case "DGBCAP": return "DGBCAP_" + data;
            case "HDCAPA": return "DCAPA_" + data;
            case "JBCAP": return "JBCAP_" + data;
            default: throw new IllegalArgumentException("Unsupported company code: " + companyCode);
        }
    }

}
