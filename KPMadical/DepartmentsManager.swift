//
//  DepartmentsManager.swift
//  KPMadical
//
//  Created by Junsung Park on 3/20/24.
//

import Foundation
enum Department: Int {
    case general = 0, internalMedicine, neurology, mentalHealth, surgery, orthopedics, neurosurgery, cardiovascularSurgery, plasticSurgery, anesthesiology, obstetricsAndGynecology, pediatrics, ophthalmology, otolaryngology, dermatology, urology, radiology, integratedRadiology, pathology, diagnosticLaboratory, tuberculosis, rehabilitation, nuclearMedicine, familyMedicine, emergencyMedicine, occupationalEnvironmentalMedicine, preventiveMedicine, otherDentistry, otherTraditional, other1 = 31, other2 = 40, health, other3, dentalHealthFacility, traditionalHealthFacility, dentistry = 49, oralMaxillofacialSurgery, prosthodontics, orthodontics, pediatricDentistry, periodontics, endodontics, oralMedicine, radiologyDentistry, oralPathology, preventiveDentistry, subDentistry, integratedDentistry, traditionalInternalMedicine = 80, traditionalGynecology, traditionalPediatrics, traditionalOphthalmologyOtorhinolaryngologyDermatology, traditionalNeuropsychiatry, acupuncture, traditionalRehabilitationMedicine, constitution, traditionalEmergency, anotherEmergency = 89, traditionalSubtotal, otherIntegrated

    var name: String {
        switch self {
        case .general: return "일반의"
        case .internalMedicine: return "내과"
        case .neurology: return "신경과"
        case .mentalHealth: return "정신건강의학과"
        case .surgery: return "외과"
        case .orthopedics: return "정형외과"
        case .neurosurgery: return "신경외과"
        case .cardiovascularSurgery: return "심장혈관흉부외과"
        case .plasticSurgery: return "성형외과"
        case .anesthesiology: return "마취통증의학과"
        case .obstetricsAndGynecology: return "산부인과"
        case .pediatrics: return "소아청소년과"
        case .ophthalmology: return "안과"
        case .otolaryngology: return "이비인후과"
        case .dermatology: return "피부과"
        case .urology: return "비뇨의학과"
        case .radiology: return "영상의학과"
        case .integratedRadiology: return "방사선과통합"
        case .pathology: return "병리과"
        case .diagnosticLaboratory: return "진단검사의학과"
        case .tuberculosis: return "결핵과"
        case .rehabilitation: return "재활의학과"
        case .nuclearMedicine: return "핵의학과"
        case .familyMedicine: return "가정의학과"
        case .emergencyMedicine: return "응급의학과"
        case .occupationalEnvironmentalMedicine: return "직업환경의학과"
        case .preventiveMedicine: return "예방의학과"
        case .otherDentistry: return "기타1(치과)"
        case .otherTraditional: return "기타4(한방)"
        case .other1: return "기타2"
        case .other2: return "기타2" // Check this, seems like a duplicate
        case .health: return "보건"
        case .other3: return "기타3"
        case .dentalHealthFacility: return "보건기관치과"
        case .traditionalHealthFacility: return "보건기관한방"
        case .dentistry: return "치과"
        case .oralMaxillofacialSurgery: return "구강악안면외과"
        case .prosthodontics: return "치과보철과"
        case .orthodontics: return "치과교정과"
        case .pediatricDentistry: return "소아치과"
        case .periodontics: return "치주과"
        case .endodontics: return "치과보존과"
        case .oralMedicine: return "구강내과"
        case .radiologyDentistry: return "영상치의학과"
        case .oralPathology: return "구강병리과"
        case .preventiveDentistry: return "예방치과"
        case .subDentistry: return "치과소계"
        case .integratedDentistry: return "통합치의학과"
        case .traditionalInternalMedicine: return "한방내과"
        case .traditionalGynecology: return "한방부인과"
        case .traditionalPediatrics: return "한방소아과"
        case .traditionalOphthalmologyOtorhinolaryngologyDermatology: return "한방안·이비인후·피부과"
        case .traditionalNeuropsychiatry: return "한방신경정신과"
        case .acupuncture: return "침구과"
        case .traditionalRehabilitationMedicine: return "한방재활의학과"
        case .constitution: return "사상체질과"
        case .traditionalEmergency: return "한방응급"
        case .anotherEmergency: return "한방응급" // Check for duplicate or different context
        case .traditionalSubtotal: return "한방소계"
        case .otherIntegrated: return "기타통합"
        }
    }
    static func departmentName(fromId id: Int) -> String? {
        guard let department = Department(rawValue: id) else {
            return nil // Return nil if no matching department found
        }
        return department.name
    }
}

// 사용 예:
//if let departmentName = Department.departmentName(fromId: 1) {
//    print(departmentName) // "내과"를 출력합니다.
//} else {
//    print("Invalid department ID")
//}

