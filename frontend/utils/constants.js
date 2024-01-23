import NatureIcon from '@mui/icons-material/Nature';
import WarningIcon from '@mui/icons-material/Warning';
import LocalHospitalIcon from '@mui/icons-material/LocalHospital';
import FoodBankIcon from '@mui/icons-material/FoodBank';
import FamilyRestroomIcon from '@mui/icons-material/FamilyRestroom';

export const categories = [
    {
        up: "Animals",
        down: "animals",
        isImportant: false
    },
    {
        up: "Business",
        down: "business",
        isImportant: false
    },
    {
        up: "Competitions",
        down: "competitions",
        isImportant: false
    },
    {
        up: "StartUp",
        down: "startup",
        isImportant: true
    },
    {
        up: "Education",
        down: "education",
        isImportant: false
    },
    {
        up: "Emergencies",
        down: "emergencies",
        isImportant: true,
        icon: WarningIcon
    },
    {
        up: "Environment",
        down: "environment",
        isImportant: true,
        icon: NatureIcon
    },
    {
        up: "Events",
        down: "events",
        isImportant: false
    },
    {
        up: "Family",
        down: "family",
        isImportant: false
    },
    {
        up: "Animals",
        down: "animals",
        isImportant: false
    },
    {
        up: "Medical",
        down: "medical",
        isImportant: true,
        icon: LocalHospitalIcon
    },
    {
        up: "Monthly Bills",
        down: "monthlyBills",
        isImportant: false
    },
    {
        up: "Charity",
        down: "charity",
        isImportant: true,
        icon: FoodBankIcon
    },
    {
        up: "Sports",
        down: "sports",
        isImportant: false
    },
    {
        up: "Other",
        down: "other",
        isImportant: true,
        icon: FamilyRestroomIcon
    },
]