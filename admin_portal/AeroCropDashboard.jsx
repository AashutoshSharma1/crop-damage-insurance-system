import React, {
  createContext,
  useContext,
  useState,
  useEffect,
  useRef,
  useCallback,
} from "react";
import {
  Satellite,
  Leaf,
  Users,
  Sprout,
  Sun,
  Moon,
  ChevronDown,
  Search,
  Thermometer,
  Hexagon,
  AlertTriangle,
  FileWarning,
  Wallet,
  ArrowUpRight,
  Radio,
  Check,
  UserPlus,
  Clock,
  MapPin,
  ChevronRight,
  X,
  Phone,
  Mail,
  ShieldCheck,
  AlertOctagon,
  XCircle,
  Eye,
  Filter,
  Activity,
  Cpu,
  Globe,
  Sparkles,
} from "lucide-react";

// ---------------------------------------------------------------------------
// Theme Context & Hook
// ---------------------------------------------------------------------------

const ThemeContext = createContext(true);
const useIsDark = () => useContext(ThemeContext);

function useTheme() {
  const dark = useIsDark();
  return {
    dark,
    page: dark ? "bg-slate-950 text-slate-100" : "bg-slate-50 text-slate-900",
    headerBorder: dark ? "border-slate-800/80" : "border-slate-200",
    headerBg: dark ? "bg-slate-950/80" : "bg-white/80",
    panel: dark
      ? "border-slate-800/80 bg-slate-900/60"
      : "border-slate-200 bg-white/80",
    panelHover: dark ? "hover:border-slate-700" : "hover:border-slate-300",
    innerBorder: dark ? "border-slate-800/80" : "border-slate-200",
    border: dark ? "border-slate-800" : "border-slate-200",
    textPrimary: dark ? "text-slate-100" : "text-slate-900",
    textMuted: dark ? "text-slate-400" : "text-slate-500",
    textFaint: dark ? "text-slate-500" : "text-slate-500",
    textFainter: dark ? "text-slate-600" : "text-slate-400",
    surface: dark ? "bg-slate-900/60" : "bg-white",
    surfaceSolid: dark ? "bg-slate-950/70" : "bg-white",
    inputText: dark ? "text-slate-200" : "text-slate-800",
    placeholder: dark ? "placeholder:text-slate-600" : "placeholder:text-slate-400",
    divide: dark ? "divide-slate-800/70" : "divide-slate-200",
    rowHover: dark ? "hover:bg-slate-800/30" : "hover:bg-slate-100",
    inactiveTab: dark
      ? "text-slate-400 hover:text-slate-200"
      : "text-slate-500 hover:text-slate-900",
    avatarBorder: dark
      ? "border-slate-800 hover:border-slate-700 bg-slate-900/60"
      : "border-slate-200 hover:border-slate-300 bg-white",
    toggleTrack: dark
      ? "bg-slate-800/80 border-slate-700"
      : "bg-slate-200 border-slate-300",
    toggleKnob: dark
      ? "bg-slate-950 border-cyan-400/40"
      : "bg-white border-cyan-500/40",
  };
}

// ---------------------------------------------------------------------------
// Static Initial & Fallback Telemetry Data
// ---------------------------------------------------------------------------

const NAV_ITEMS = ["Dashboard", "Field Officers", "Farmers"];

const STATUS_STYLES = {
  Pending: "text-amber-600 dark:text-amber-300 bg-amber-400/10 border-amber-400/30",
  Approved: "text-emerald-600 dark:text-emerald-300 bg-emerald-400/10 border-emerald-400/30",
  Flagged: "text-rose-600 dark:text-rose-300 bg-rose-400/10 border-rose-400/30",
  Rejected: "text-slate-600 dark:text-slate-400 bg-slate-400/10 border-slate-400/30",
};

const INITIAL_CLAIMS = [
  {
    id: "CLM-2026-891",
    farmer: "Rajesh Kumar",
    farmerId: "FARMER_101",
    fieldId: "FLD-2041",
    crop: "Wheat",
    reason: "Unseasonal Hailstorm & Heavy Rain",
    time: "14 min ago",
    status: "Pending",
    photoUrls: [
      "https://images.unsplash.com/photo-1574943320219-553eb213f72d?w=600&auto=format&fit=crop&q=80",
      "https://images.unsplash.com/photo-1500937386664-56d1dfef3854?w=600&auto=format&fit=crop&q=80",
    ],
    description: "Heavy hailstorm damaged Wheat crop at jointing stage. 40% lodging noticed.",
    assignedOfficer: "Inspector D. Sharma",
    estimatedPayout: 35000,
    officerNotes: "Ground verification in progress.",
    mlAnalysis: {
      damagePercentage: 42.5,
      confidenceScore: 91.8,
      severity: "HIGH",
      detectedHazard: "Unseasonal Hailstorm Lodging & Leaf Shredding",
      modelVersion: "PyTorch CropVision-v2.4 (.pth)",
    },
    sentinelNdvi: {
      preDamageNdvi: 0.78,
      postDamageNdvi: 0.41,
      ndviDropPercent: 47.4,
      satelliteDamageEstimate: 44.0,
      acquisitionDate: "2026-09-04 Copernicus Sentinel-2B",
    },
    fresh: false,
  },
  {
    id: "CLM-2026-442",
    farmer: "Suresh Singh",
    farmerId: "FARMER_102",
    fieldId: "FLD-1988",
    crop: "Cotton",
    reason: "Hailstorm impact",
    time: "26 min ago",
    status: "Flagged",
    photoUrls: [
      "https://images.unsplash.com/photo-1530507629858-e4977d30e9e0?w=600&auto=format&fit=crop&q=80",
    ],
    description: "Stem borer infestation spotted across 2 acres. Foliage severely damaged.",
    assignedOfficer: "Inspector A. Verma",
    estimatedPayout: 18000,
    officerNotes: "High pest activity flagged by satellite telemetry.",
    mlAnalysis: {
      damagePercentage: 68.0,
      confidenceScore: 94.2,
      severity: "HIGH",
      detectedHazard: "Stem Borer Foliage Defoliation",
      modelVersion: "PyTorch CropVision-v2.4 (.pth)",
    },
    sentinelNdvi: {
      preDamageNdvi: 0.82,
      postDamageNdvi: 0.32,
      ndviDropPercent: 60.9,
      satelliteDamageEstimate: 65.5,
      acquisitionDate: "2026-09-04 Copernicus Sentinel-2B",
    },
    fresh: false,
  },
  {
    id: "CLM-2026-105",
    farmer: "Anita Devi",
    farmerId: "FARMER_103",
    fieldId: "FLD-2210",
    crop: "Soybean",
    reason: "Pest infestation",
    time: "45 min ago",
    status: "Approved",
    photoUrls: [
      "https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=600&auto=format&fit=crop&q=80",
    ],
    description: "Field flooded due to continuous heavy downpour for 36 hours.",
    assignedOfficer: "Inspector S. Patil",
    estimatedPayout: 42000,
    officerNotes: "Approved by regional crop insurance committee.",
    mlAnalysis: {
      damagePercentage: 35.0,
      confidenceScore: 88.5,
      severity: "MODERATE",
      detectedHazard: "Waterlogging Root Saturation",
      modelVersion: "PyTorch CropVision-v2.4 (.pth)",
    },
    sentinelNdvi: {
      preDamageNdvi: 0.74,
      postDamageNdvi: 0.49,
      ndviDropPercent: 33.7,
      satelliteDamageEstimate: 36.0,
      acquisitionDate: "2026-09-04 Copernicus Sentinel-2B",
    },
    fresh: false,
  },
  {
    id: "CLM-2026-309",
    farmer: "Meena Kulkarni",
    farmerId: "FARMER_104",
    fieldId: "FLD-2078",
    crop: "Maize",
    reason: "Flood damage",
    time: "1 hour ago",
    status: "Pending",
    photoUrls: [
      "https://images.unsplash.com/photo-1563514227147-6d2ff665a6a0?w=600&auto=format&fit=crop&q=80",
    ],
    description: "Excess rainwater accumulation in low-lying basin zone.",
    assignedOfficer: "Unassigned",
    estimatedPayout: 0,
    officerNotes: null,
    mlAnalysis: {
      damagePercentage: 52.0,
      confidenceScore: 90.1,
      severity: "HIGH",
      detectedHazard: "Submerged Root Stress",
      modelVersion: "PyTorch CropVision-v2.4 (.pth)",
    },
    sentinelNdvi: {
      preDamageNdvi: 0.80,
      postDamageNdvi: 0.38,
      ndviDropPercent: 52.5,
      satelliteDamageEstimate: 50.0,
      acquisitionDate: "2026-09-04 Copernicus Sentinel-2B",
    },
    fresh: false,
  },
  {
    id: "CLM-2026-512",
    farmer: "Devendra Singh",
    farmerId: "FARMER_105",
    fieldId: "FLD-1902",
    crop: "Rice",
    reason: "Wind lodging",
    time: "2 hours ago",
    status: "Approved",
    photoUrls: [
      "https://images.unsplash.com/photo-1535242208474-9a279b24b270?w=600&auto=format&fit=crop&q=80",
    ],
    description: "High velocity wind caused 30% crop lodging prior to harvest.",
    assignedOfficer: "Inspector R. Deshmukh",
    estimatedPayout: 28500,
    officerNotes: "Verified by drone imagery.",
    mlAnalysis: {
      damagePercentage: 28.0,
      confidenceScore: 92.4,
      severity: "MODERATE",
      detectedHazard: "Pre-harvest Lodging",
      modelVersion: "PyTorch CropVision-v2.4 (.pth)",
    },
    sentinelNdvi: {
      preDamageNdvi: 0.79,
      postDamageNdvi: 0.58,
      ndviDropPercent: 26.5,
      satelliteDamageEstimate: 27.5,
      acquisitionDate: "2026-09-04 Copernicus Sentinel-2B",
    },
    fresh: false,
  },
];

const INITIAL_OFFICERS = [
  {
    id: "OFFICER_201",
    name: "Inspector D. Sharma",
    email: "officer.karnal@agri.in",
    phone: "+91 98123 45678",
    zone: "Karnal North Zone",
    activeClaimsCount: 3,
    totalVerified: 42,
    status: "Active",
  },
  {
    id: "OFFICER_202",
    name: "Inspector A. Verma",
    email: "verma.indore@agri.in",
    phone: "+91 98234 56789",
    zone: "Indore West Zone",
    activeClaimsCount: 2,
    totalVerified: 38,
    status: "Active",
  },
  {
    id: "OFFICER_203",
    name: "Inspector S. Patil",
    email: "patil.punjab@agri.in",
    phone: "+91 98345 67890",
    zone: "Punjab Central Belt",
    activeClaimsCount: 1,
    totalVerified: 56,
    status: "Active",
  },
  {
    id: "OFFICER_204",
    name: "Inspector R. Deshmukh",
    email: "deshmukh.nashik@agri.in",
    phone: "+91 98456 78901",
    zone: "Nashik Agricultural Zone",
    activeClaimsCount: 2,
    totalVerified: 29,
    status: "On Field",
  },
];

const INITIAL_FARMERS = [
  {
    id: "FARMER_101",
    name: "Rajesh Kumar",
    phone: "+91 98765 43210",
    email: "rajesh.farmer@agri.in",
    fieldAddress: "Khasra No. 114/2, North Rampur Fields, Karnal",
    crop: "Wheat",
    areaAcres: 4.2,
    latitude: 29.6857,
    longitude: 76.9905,
    policyStatus: "Active Insured",
    activeClaimsCount: 1,
    totalPayout: 35000,
    polygon: [
      [29.6865, 76.9895],
      [29.6870, 76.9915],
      [29.6848, 76.9920],
      [29.6845, 76.9898],
    ],
  },
  {
    id: "FARMER_102",
    name: "Suresh Singh",
    phone: "+91 98765 43211",
    email: "suresh.farmer@agri.in",
    fieldAddress: "Plot 88, Sonipat Agricultural Zone, Haryana",
    crop: "Cotton",
    areaAcres: 6.5,
    latitude: 28.9931,
    longitude: 77.0151,
    policyStatus: "Active Insured",
    activeClaimsCount: 1,
    totalPayout: 18000,
    polygon: [
      [28.9940, 77.0140],
      [28.9945, 77.0160],
      [28.9920, 77.0165],
      [28.9918, 77.0142],
    ],
  },
  {
    id: "FARMER_103",
    name: "Anita Devi",
    phone: "+91 98765 43212",
    email: "anita.farmer@agri.in",
    fieldAddress: "Field 12B, Panipat Mustard Belt, Haryana",
    crop: "Soybean",
    areaAcres: 3.0,
    latitude: 29.5215,
    longitude: 76.6022,
    policyStatus: "Active Insured",
    activeClaimsCount: 1,
    totalPayout: 42000,
    polygon: [
      [29.5225, 76.6012],
      [29.5230, 76.6032],
      [29.5205, 76.6035],
      [29.5200, 76.6015],
    ],
  },
  {
    id: "FARMER_104",
    name: "Meena Kulkarni",
    phone: "+91 98765 43213",
    email: "meena.farmer@agri.in",
    fieldAddress: "Khasra 204, Indore West Belt, Madhya Pradesh",
    crop: "Maize",
    areaAcres: 5.1,
    latitude: 22.7196,
    longitude: 75.8577,
    policyStatus: "Under Review",
    activeClaimsCount: 1,
    totalPayout: 0,
    polygon: [
      [22.7205, 75.8565],
      [22.7210, 75.8585],
      [22.7188, 75.8590],
      [22.7185, 75.8570],
    ],
  },
  {
    id: "FARMER_105",
    name: "Devendra Singh",
    phone: "+91 98765 43214",
    email: "devendra.farmer@agri.in",
    fieldAddress: "Khasra 109, Ludhiana Paddy Sector, Punjab",
    crop: "Rice",
    areaAcres: 8.0,
    latitude: 30.9010,
    longitude: 75.8573,
    policyStatus: "Active Insured",
    activeClaimsCount: 1,
    totalPayout: 28500,
    polygon: [
      [30.9020, 75.8560],
      [30.9025, 75.8580],
      [30.9000, 75.8585],
      [30.8995, 75.8565],
    ],
  },
];

// ---------------------------------------------------------------------------
// Base UI Components
// ---------------------------------------------------------------------------

function GlassPanel({ children, className = "" }) {
  const t = useTheme();
  return (
    <div
      className={`rounded-xl border backdrop-blur-md shadow-[0_0_0_1px_rgba(255,255,255,0.02)] ${t.panel} ${className}`}
    >
      {children}
    </div>
  );
}

function MetricCard({ icon: Icon, label, value, sub, tone = "cyan", pulse = false, children }) {
  const t = useTheme();
  const toneMap = {
    cyan: { ring: "ring-cyan-400/20", icon: "text-cyan-600 dark:text-cyan-300 bg-cyan-400/10", text: "text-cyan-600 dark:text-cyan-300" },
    emerald: { ring: "ring-emerald-400/20", icon: "text-emerald-600 dark:text-emerald-300 bg-emerald-400/10", text: "text-emerald-600 dark:text-emerald-300" },
    amber: { ring: "ring-amber-400/20", icon: "text-amber-600 dark:text-amber-300 bg-amber-400/10", text: "text-amber-600 dark:text-amber-300" },
    rose: { ring: "ring-rose-400/20", icon: "text-rose-600 dark:text-rose-300 bg-rose-400/10", text: "text-rose-600 dark:text-rose-300" },
  }[tone];

  return (
    <GlassPanel
      className={`relative overflow-hidden p-2.5 sm:p-4 ring-1 ${toneMap.ring} ${t.panelHover} transition-colors duration-300`}
    >
      {pulse && (
        <span className="absolute top-2.5 right-2.5 sm:top-3 sm:right-3 flex h-2 w-2">
          <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-rose-400 opacity-75" />
          <span className="relative inline-flex rounded-full h-2 w-2 bg-rose-400" />
        </span>
      )}
      <div className="flex items-start justify-between">
        <div className={`p-1.5 sm:p-2 rounded-lg ${toneMap.icon}`}>
          <Icon size={16} strokeWidth={1.75} className="sm:w-[18px] sm:h-[18px]" />
        </div>
      </div>
      <div className="mt-2.5 sm:mt-4">
        <p className={`text-base sm:text-2xl font-semibold ${t.textPrimary} tabular-nums leading-tight`}>{value}</p>
        <p className={`text-[11px] sm:text-sm ${t.textMuted} mt-0.5 truncate`}>{label}</p>
      </div>
      {sub && (
        <div className={`mt-2 sm:mt-3 hidden sm:flex items-center gap-1 text-xs font-medium ${toneMap.text}`}>
          {sub}
        </div>
      )}
      {children}
    </GlassPanel>
  );
}

// ---------------------------------------------------------------------------
// Top Navigation Header
// ---------------------------------------------------------------------------

function TopNav({ activeTab, setActiveTab, darkMode, setDarkMode }) {
  const t = useTheme();
  return (
    <header className={`sticky top-0 z-30 border-b ${t.headerBorder} ${t.headerBg} backdrop-blur-md`}>
      <div className="max-w-[1600px] mx-auto px-5 h-16 flex items-center justify-between gap-6">
        {/* Logo */}
        <div className="flex items-center gap-3 shrink-0">
          <div className="relative">
            <div className="absolute inset-0 rounded-lg bg-cyan-400/30 blur-md" />
            <div className="relative p-2 rounded-lg bg-gradient-to-br from-cyan-500/20 to-emerald-500/10 border border-cyan-400/30">
              <Leaf size={18} className="text-cyan-600 dark:text-cyan-300" strokeWidth={1.75} />
            </div>
          </div>
          <div className="leading-tight">
            <p className={`${t.textPrimary} font-semibold text-sm tracking-tight`}>
              AERO-CROP <span className={t.textFaint + " font-normal"}>// Admin HUD</span>
            </p>
            <p className={`text-[11px] ${t.textFaint}`}>Crop Insurance Command Center</p>
          </div>
        </div>

        {/* Nav tabs */}
        <nav className={`hidden md:flex items-center gap-1 ${t.surface} border ${t.border} rounded-full p-1`}>
          {NAV_ITEMS.map((item) => (
            <button
              key={item}
              onClick={() => setActiveTab(item)}
              className={`relative px-4 py-1.5 rounded-full text-sm font-medium transition-all duration-200 ${
                activeTab === item
                  ? "text-slate-950 bg-cyan-300 shadow-[0_0_16px_rgba(34,211,238,0.5)]"
                  : t.inactiveTab
              }`}
            >
              {item}
            </button>
          ))}
        </nav>

        {/* Right cluster */}
        <div className="flex items-center gap-3 shrink-0">
          <div className="hidden lg:flex items-center gap-2 px-3 py-1.5 rounded-full border border-emerald-400/30 bg-emerald-400/5">
            <span className="relative flex h-1.5 w-1.5">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
              <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-emerald-400" />
            </span>
            <span className="text-[11px] font-medium text-emerald-600 dark:text-emerald-300 tracking-wide">
              LIVE COPERNICUS &amp; ML SYNC
            </span>
          </div>

          <button
            onClick={() => setDarkMode((d) => !d)}
            aria-label="Toggle dark mode"
            className={`relative w-14 h-8 rounded-full border ${t.toggleTrack} flex items-center px-1 transition-colors focus:outline-none focus:ring-2 focus:ring-cyan-400/50`}
          >
            <span
              className={`absolute top-0.5 left-0.5 h-6 w-6 rounded-full border ${t.toggleKnob} flex items-center justify-center transition-transform duration-300 ${
                darkMode ? "translate-x-6" : "translate-x-0"
              }`}
            >
              {darkMode ? (
                <Moon size={12} className="text-cyan-300" />
              ) : (
                <Sun size={12} className="text-amber-500" />
              )}
            </span>
          </button>

          <button className={`flex items-center gap-2 pl-1 pr-2 py-1 rounded-full border ${t.avatarBorder} transition-colors`}>
            <div className="w-7 h-7 rounded-full bg-gradient-to-br from-cyan-400 to-emerald-500 flex items-center justify-center text-[11px] font-semibold text-slate-950">
              AK
            </div>
            <ChevronDown size={14} className={t.textFaint} />
          </button>
        </div>
      </div>
    </header>
  );
}

// ---------------------------------------------------------------------------
// 4 Top Metric Cards (Left 70% Header)
// ---------------------------------------------------------------------------

function MetricsRow({ pendingCount = 142 }) {
  return (
    <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
      <MetricCard
        icon={Sprout}
        label="Total Managed Farms"
        value="12,480 ha"
        tone="cyan"
        sub={
          <>
            <ArrowUpRight size={14} />
            <span>+4.2% vs last quarter</span>
          </>
        }
      />

      <MetricCard
        icon={AlertTriangle}
        label="Active Risk Alerts"
        value="18"
        tone="rose"
        pulse
        sub={<span>High-alert zones flagged today</span>}
      />

      <MetricCard
        icon={FileWarning}
        label="Pending Claims"
        value={pendingCount.toString()}
        tone="amber"
        sub={
          <button className="flex items-center gap-1 hover:opacity-80 transition-opacity">
            <span>Needing review</span>
            <ChevronRight size={13} />
          </button>
        }
      />

      <MetricCard icon={Wallet} label="Total Insured Value" value="$48.5M" tone="emerald">
        <div className="mt-3">
          <div className="h-1.5 rounded-full bg-slate-300/50 dark:bg-slate-800 overflow-hidden">
            <div className="h-full w-[72%] rounded-full bg-gradient-to-r from-emerald-400 to-cyan-300" />
          </div>
          <p className="mt-1.5 text-xs text-slate-500 hidden sm:block">72% of $67M coverage cap</p>
        </div>
      </MetricCard>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Interactive OpenStreetMap / Esri Satellite Leaflet Map Panel (Left 70%)
// ---------------------------------------------------------------------------

function LeafletMapPanel({ searchQuery, setSearchQuery, farmers }) {
  const t = useTheme();
  const mapContainerRef = useRef(null);
  const mapInstanceRef = useRef(null);
  const tileLayerRef = useRef(null);

  const [mapType, setMapType] = useState("satellite");

  useEffect(() => {
    if (!mapContainerRef.current) return;
    if (mapInstanceRef.current) return;
    if (!window.L) return;

    const L = window.L;

    const map = L.map(mapContainerRef.current, {
      center: [29.6857, 76.9905],
      zoom: 12,
      zoomControl: false,
    });

    L.control.zoom({ position: "bottomright" }).addTo(map);

    const satelliteUrl = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}";
    const tileLayer = L.tileLayer(satelliteUrl, {
      maxZoom: 18,
      attribution: "Tiles &copy; Esri",
    }).addTo(map);

    tileLayerRef.current = tileLayer;
    mapInstanceRef.current = map;

    farmers.forEach((farmer) => {
      if (farmer.polygon) {
        const poly = L.polygon(farmer.polygon, {
          color: farmer.activeClaimsCount > 0 ? "#fb5a72" : "#10e0a0",
          weight: 2.5,
          fillColor: farmer.activeClaimsCount > 0 ? "#fb5a72" : "#10e0a0",
          fillOpacity: 0.25,
        }).addTo(map);

        poly.bindPopup(`
          <div style="font-family: sans-serif; font-size: 12px; color: #0f172a; padding: 4px;">
            <strong style="color: #0d9488; font-size: 13px;">${farmer.name}</strong><br/>
            <span>Field: ${farmer.fieldAddress}</span><br/>
            <span>Crop: <strong>${farmer.crop}</strong> (${farmer.areaAcres} acres)</span><br/>
            <span style="color: ${farmer.activeClaimsCount > 0 ? '#e11d48' : '#059669'}; font-weight: bold;">
              ${farmer.activeClaimsCount > 0 ? "⚠ Active Claim Flagged" : "✔ Normal Canopy"}
            </span>
          </div>
        `);
      }

      const marker = L.marker([farmer.latitude, farmer.longitude]).addTo(map);
      marker.bindPopup(`
        <div style="font-family: sans-serif; font-size: 12px; color: #0f172a;">
          <strong style="font-size: 13px;">${farmer.name}</strong><br/>
          <span>${farmer.crop} Farm Telemetry</span>
        </div>
      `);
    });

    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove();
        mapInstanceRef.current = null;
      }
    };
  }, [farmers]);

  const handleMapTypeSwitch = (type) => {
    setMapType(type);
    if (!mapInstanceRef.current || !window.L) return;
    const L = window.L;

    if (tileLayerRef.current) {
      mapInstanceRef.current.removeLayer(tileLayerRef.current);
    }

    if (type === "satellite") {
      tileLayerRef.current = L.tileLayer("https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}", {
        maxZoom: 18,
      }).addTo(mapInstanceRef.current);
    } else {
      tileLayerRef.current = L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
        maxZoom: 19,
      }).addTo(mapInstanceRef.current);
    }
  };

  useEffect(() => {
    if (!searchQuery || !mapInstanceRef.current) return;
    const matched = farmers.find(
      (f) =>
        f.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        f.fieldAddress.toLowerCase().includes(searchQuery.toLowerCase())
    );
    if (matched) {
      mapInstanceRef.current.setView([matched.latitude, matched.longitude], 15);
    }
  }, [searchQuery, farmers]);

  return (
    <GlassPanel className="flex flex-col h-full overflow-hidden">
      <div className={`flex items-center justify-between p-4 border-b ${t.innerBorder}`}>
        <div>
          <h2 className={`${t.textPrimary} font-semibold text-sm flex items-center gap-2`}>
            <Globe className="text-cyan-400" size={16} />
            Live Geospatial Intelligence &amp; Sentinel Map
          </h2>
          <p className={`text-xs ${t.textFaint} mt-0.5`}>Real Leaflet OpenStreetMap &amp; Esri Satellite Telemetry</p>
        </div>
        <div className={`hidden sm:flex items-center gap-1.5 text-xs ${t.textFaint}`}>
          <MapPin size={13} className="text-cyan-500 dark:text-cyan-400" />
          Karnal &amp; Indore Agronomic Zone
        </div>
      </div>

      <div className={`flex flex-col sm:flex-row gap-2 p-3 border-b ${t.innerBorder}`}>
        <div className="relative flex-1">
          <Search size={14} className={`absolute left-3 top-1/2 -translate-y-1/2 ${t.textFaint}`} />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search farmer name, district or field ID (e.g. Rajesh Kumar)..."
            className={`w-full pl-8 pr-3 py-1.5 rounded-lg ${t.surfaceSolid} border ${t.border} text-xs ${t.inputText} ${t.placeholder} focus:outline-none focus:border-cyan-400/60 focus:ring-1 focus:ring-cyan-400/40 transition-colors`}
          />
        </div>

        <div className="flex items-center gap-1.5">
          <button
            onClick={() => handleMapTypeSwitch("satellite")}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg border text-[11px] font-medium transition-colors ${
              mapType === "satellite"
                ? "border-cyan-400/40 bg-cyan-400/10 text-cyan-300 font-bold"
                : `${t.border} ${t.textFaint} hover:opacity-80`
            }`}
          >
            <Satellite size={12} />
            Esri Satellite
          </button>
          <button
            onClick={() => handleMapTypeSwitch("osm")}
            className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg border text-[11px] font-medium transition-colors ${
              mapType === "osm"
                ? "border-cyan-400/40 bg-cyan-400/10 text-cyan-300 font-bold"
                : `${t.border} ${t.textFaint} hover:opacity-80`
            }`}
          >
            <Globe size={12} />
            OpenStreetMap
          </button>
        </div>
      </div>

      <div className="relative flex-1 min-h-[460px]">
        <div ref={mapContainerRef} className="w-full h-full min-h-[460px] z-10" />

        <div className={`absolute bottom-4 left-4 z-20 flex items-center gap-3 px-3 py-2 rounded-lg ${t.surfaceSolid} border ${t.border} backdrop-blur-md shadow-xl`}>
          <div className="flex items-center gap-1.5 text-[10px]">
            <span className="w-2.5 h-2.5 rounded-full bg-emerald-400" />
            <span className={t.textMuted}>Low Risk / Normal</span>
          </div>
          <div className="flex items-center gap-1.5 text-[10px]">
            <span className="w-2.5 h-2.5 rounded-full bg-rose-500" />
            <span className={t.textMuted}>High Risk / Claim Flagged</span>
          </div>
        </div>

        <div className={`absolute top-4 right-4 z-20 px-3 py-1.5 rounded-md ${t.surfaceSolid} border ${t.border} text-[10px] ${t.textFaint} font-mono flex items-center gap-2 shadow-xl`}>
          <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping" />
          <span>Copernicus Sentinel-2B Live Telemetry</span>
        </div>
      </div>
    </GlassPanel>
  );
}

// ---------------------------------------------------------------------------
// Claims Feed (Right 30% Column: Active Claims to Watch)
// ---------------------------------------------------------------------------

function ClaimsFeed({ claims, onReview, onAssign }) {
  const t = useTheme();

  return (
    <GlassPanel className="flex flex-col h-full overflow-hidden">
      <div className={`flex items-center justify-between p-4 border-b ${t.innerBorder}`}>
        <div>
          <h2 className={`${t.textPrimary} font-semibold text-sm`}>Claims to Watch</h2>
          <p className={`text-xs ${t.textFaint} mt-0.5`}>Live queue, newest activity first</p>
        </div>
        <div className="flex items-center gap-1.5 px-2.5 py-1 rounded-full border border-emerald-400/30 bg-emerald-400/5">
          <span className="relative flex h-1.5 w-1.5">
            <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75" />
            <span className="relative inline-flex rounded-full h-1.5 w-1.5 bg-emerald-400" />
          </span>
          <span className="text-[10px] font-medium text-emerald-600 dark:text-emerald-300 tracking-wide">
            REAL-TIME SYNC ON
          </span>
        </div>
      </div>

      <div className={`flex-1 overflow-y-auto divide-y ${t.divide} max-h-[640px]`}>
        {claims.length === 0 ? (
          <div className="p-8 text-center text-xs text-slate-500">No active claims found matching query.</div>
        ) : (
          claims.map((claim) => (
            <ClaimRow key={claim.id} claim={claim} onReview={onReview} onAssign={onAssign} />
          ))
        )}
      </div>
    </GlassPanel>
  );
}

function ClaimRow({ claim, onReview, onAssign }) {
  const t = useTheme();
  const [entered, setEntered] = useState(!claim.fresh);

  useEffect(() => {
    if (claim.fresh) {
      const raf = requestAnimationFrame(() => setEntered(true));
      return () => cancelAnimationFrame(raf);
    }
  }, [claim.fresh]);

  return (
    <div
      className={`p-4 transition-all duration-500 ease-out ${
        entered ? "opacity-100 translate-y-0" : "opacity-0 -translate-y-2"
      } ${claim.fresh ? "bg-cyan-400/[0.06]" : ""} ${t.rowHover}`}
    >
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <div className="flex items-center gap-2">
            <p className={`text-sm font-medium ${t.textPrimary} truncate`}>{claim.farmer}</p>
            <span
              className={`text-[10px] px-1.5 py-0.5 rounded-full border font-medium ${
                STATUS_STYLES[claim.status] || STATUS_STYLES.Pending
              }`}
            >
              {claim.status}
            </span>
          </div>
          <p className={`text-xs ${t.textFaint} mt-0.5`}>
            {claim.fieldId} · {claim.crop} · {claim.reason}
          </p>

          <div className="flex items-center gap-2 mt-1.5">
            {claim.mlAnalysis && (
              <span className="text-[10px] px-2 py-0.5 rounded-md bg-purple-500/10 border border-purple-500/30 text-purple-300 font-mono font-semibold flex items-center gap-1">
                <Cpu size={10} />
                ML: {claim.mlAnalysis.damagePercentage}% Loss
              </span>
            )}
            {claim.sentinelNdvi && (
              <span className="text-[10px] px-2 py-0.5 rounded-md bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 font-mono font-semibold flex items-center gap-1">
                <Satellite size={10} />
                NDVI: -{claim.sentinelNdvi.ndviDropPercent}% Drop
              </span>
            )}
          </div>

          <div className={`flex items-center gap-1 text-[11px] ${t.textFainter} mt-1.5`}>
            <Clock size={11} />
            {claim.time}
          </div>
        </div>

        <div className="flex flex-col gap-1.5 shrink-0">
          <button
            onClick={() => onReview(claim)}
            className="flex items-center gap-1 px-2.5 py-1 rounded-md border border-cyan-400/30 bg-cyan-400/10 text-cyan-600 dark:text-cyan-300 text-[11px] font-medium hover:bg-cyan-400/20 transition-colors"
          >
            <Check size={12} />
            Review
          </button>
          <button
            onClick={() => onAssign(claim)}
            className={`flex items-center gap-1 px-2.5 py-1 rounded-md border ${t.border} ${t.textMuted} text-[11px] font-medium hover:opacity-80 transition-colors`}
          >
            <UserPlus size={12} />
            Assign
          </button>
        </div>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Review Claim Modal (With PyTorch ML & Copernicus Sentinel NDVI Cards)
// ---------------------------------------------------------------------------

function ReviewClaimModal({ claim, onClose, onUpdateStatus }) {
  const t = useTheme();
  const [remarks, setRemarks] = useState(claim.officerNotes || "");
  const [payout, setPayout] = useState(claim.estimatedPayout || 35000);
  const [selectedPhoto, setSelectedPhoto] = useState(claim.photoUrls?.[0] || null);

  if (!claim) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className={`relative w-full max-w-3xl max-h-[92vh] overflow-y-auto rounded-2xl border ${t.panel} ${t.surfaceSolid} p-6 shadow-2xl flex flex-col gap-5`}>
        <div className="flex items-start justify-between border-b pb-4 border-slate-800">
          <div>
            <div className="flex items-center gap-2">
              <h3 className={`text-lg font-bold ${t.textPrimary}`}>{claim.id} — Claim &amp; Damage Audit</h3>
              <span className={`text-xs px-2.5 py-0.5 rounded-full border font-semibold ${STATUS_STYLES[claim.status] || STATUS_STYLES.Pending}`}>
                {claim.status}
              </span>
            </div>
            <p className={`text-xs ${t.textMuted} mt-1`}>
              Farmer: <span className="font-semibold text-cyan-400">{claim.farmer}</span> ({claim.fieldId}) · Crop: {claim.crop}
            </p>
          </div>
          <button onClick={onClose} className="p-1 rounded-lg hover:bg-slate-800 text-slate-400">
            <X size={18} />
          </button>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          <div className="p-3.5 rounded-xl border border-purple-500/30 bg-purple-500/[0.06] space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold text-purple-300 uppercase tracking-wider flex items-center gap-1.5">
                <Cpu size={14} className="text-purple-400" />
                PyTorch ML Photo Assessment (.pth)
              </span>
              <span className="text-[10px] px-2 py-0.5 rounded bg-purple-500/20 text-purple-300 font-mono">
                {claim.mlAnalysis?.modelVersion || "CropVision-v2.4"}
              </span>
            </div>
            <div className="flex items-baseline justify-between pt-1">
              <div>
                <p className="text-2xl font-black text-purple-300 tabular-nums">
                  {claim.mlAnalysis?.damagePercentage || 42.5}%
                </p>
                <p className="text-[10px] text-purple-400/80 font-medium">Estimated Field Damage</p>
              </div>
              <div className="text-right">
                <p className="text-xs font-bold text-emerald-400">{claim.mlAnalysis?.confidenceScore || 91.8}%</p>
                <p className="text-[10px] text-slate-400">Model Confidence</p>
              </div>
            </div>
            <p className="text-[11px] text-slate-300 bg-purple-950/40 p-2 rounded-lg border border-purple-800/40">
              <span className="font-semibold text-purple-300">Detected Hazard: </span>
              {claim.mlAnalysis?.detectedHazard || "Unseasonal Hailstorm Lodging & Leaf Shredding"}
            </p>
          </div>

          <div className="p-3.5 rounded-xl border border-emerald-500/30 bg-emerald-500/[0.06] space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold text-emerald-300 uppercase tracking-wider flex items-center gap-1.5">
                <Satellite size={14} className="text-emerald-400" />
                Copernicus Sentinel-2 Live NDVI
              </span>
              <span className="text-[10px] px-2 py-0.5 rounded bg-emerald-500/20 text-emerald-300 font-mono">
                Sentinel-2B L2A
              </span>
            </div>
            <div className="flex items-baseline justify-between pt-1">
              <div>
                <p className="text-2xl font-black text-emerald-300 tabular-nums">
                  {claim.sentinelNdvi?.satelliteDamageEstimate || 44.0}%
                </p>
                <p className="text-[10px] text-emerald-400/80 font-medium">Satellite Canopy Loss</p>
              </div>
              <div className="text-right">
                <p className="text-xs font-bold text-rose-400">-{claim.sentinelNdvi?.ndviDropPercent || 47.4}%</p>
                <p className="text-[10px] text-slate-400">NDVI Degradation</p>
              </div>
            </div>
            <div className="text-[11px] text-slate-300 bg-emerald-950/40 p-2 rounded-lg border border-emerald-800/40 flex justify-between">
              <span>Pre-Damage NDVI: <strong className="text-emerald-400">{claim.sentinelNdvi?.preDamageNdvi || 0.78}</strong></span>
              <span>Post-Damage NDVI: <strong className="text-rose-400">{claim.sentinelNdvi?.postDamageNdvi || 0.41}</strong></span>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div className="space-y-3">
            <div className="p-3 rounded-lg border border-slate-800 bg-slate-900/40">
              <p className="text-[11px] font-semibold text-slate-400 uppercase tracking-wider">Farmer Explanation</p>
              <p className="text-sm font-semibold text-rose-400 mt-0.5">{claim.reason}</p>
              <p className="text-xs text-slate-300 mt-1 leading-relaxed">{claim.description}</p>
            </div>

            <div className="p-3 rounded-lg border border-slate-800 bg-slate-900/40 space-y-1 text-xs">
              <div className="flex justify-between text-slate-400">
                <span>Field Inspector:</span>
                <span className="font-semibold text-cyan-300">{claim.assignedOfficer || "Unassigned"}</span>
              </div>
              <div className="flex justify-between text-slate-400">
                <span>Submission Window:</span>
                <span className="font-mono text-slate-300">{claim.time}</span>
              </div>
            </div>
          </div>

          <div className="space-y-2">
            <p className="text-xs font-semibold text-slate-400">Proof Field Photos ({claim.photoUrls?.length || 0})</p>
            <div className="h-40 rounded-xl overflow-hidden border border-slate-800 bg-slate-900 flex items-center justify-center relative">
              {selectedPhoto ? (
                <img src={selectedPhoto} alt="Proof Field" className="w-full h-full object-cover" />
              ) : (
                <div className="flex flex-col items-center gap-1 text-slate-500">
                  <Eye size={24} />
                  <span className="text-xs">No photos attached</span>
                </div>
              )}
            </div>
            {claim.photoUrls?.length > 1 && (
              <div className="flex gap-2 overflow-x-auto">
                {claim.photoUrls.map((url, idx) => (
                  <button
                    key={idx}
                    onClick={() => setSelectedPhoto(url)}
                    className={`w-12 h-12 rounded-lg overflow-hidden border ${
                      selectedPhoto === url ? "border-cyan-400 ring-1 ring-cyan-400" : "border-slate-800 opacity-60"
                    }`}
                  >
                    <img src={url} alt="thumbnail" className="w-full h-full object-cover" />
                  </button>
                ))}
              </div>
            )}
          </div>
        </div>

        <div className="space-y-3 border-t pt-4 border-slate-800">
          <div>
            <label className="text-xs font-semibold text-slate-400">Estimated Claim Payout ($ / ₹)</label>
            <input
              type="number"
              value={payout}
              onChange={(e) => setPayout(Number(e.target.value))}
              className="mt-1 w-full px-3 py-2 rounded-lg bg-slate-900 border border-slate-800 text-sm text-slate-100 focus:border-cyan-400 focus:outline-none"
            />
          </div>

          <div>
            <label className="text-xs font-semibold text-slate-400">Inspector &amp; Admin Audit Notes</label>
            <textarea
              rows={2}
              value={remarks}
              onChange={(e) => setRemarks(e.target.value)}
              placeholder="Add ground audit findings or rejection rationale..."
              className="mt-1 w-full px-3 py-2 rounded-lg bg-slate-900 border border-slate-800 text-xs text-slate-100 focus:border-cyan-400 focus:outline-none"
            />
          </div>
        </div>

        <div className="flex items-center justify-end gap-2 border-t pt-4 border-slate-800">
          <button
            onClick={() => onUpdateStatus(claim.id, "Rejected", remarks, payout)}
            className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-rose-500/10 border border-rose-500/30 text-rose-400 text-xs font-semibold hover:bg-rose-500/20"
          >
            <XCircle size={14} />
            Reject Claim
          </button>
          <button
            onClick={() => onUpdateStatus(claim.id, "Flagged", remarks, payout)}
            className="flex items-center gap-1.5 px-3 py-2 rounded-lg bg-amber-500/10 border border-amber-500/30 text-amber-400 text-xs font-semibold hover:bg-amber-500/20"
          >
            <AlertOctagon size={14} />
            Flag for Re-inspection
          </button>
          <button
            onClick={() => onUpdateStatus(claim.id, "Approved", remarks, payout)}
            className="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-emerald-400 text-slate-950 text-xs font-bold hover:bg-emerald-300 shadow-[0_0_16px_rgba(16,185,129,0.3)]"
          >
            <ShieldCheck size={14} />
            Approve Claim Payout
          </button>
        </div>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Assign Officer Modal
// ---------------------------------------------------------------------------

function AssignOfficerModal({ claim, officers, onClose, onAssignOfficer }) {
  const t = useTheme();
  if (!claim) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className={`relative w-full max-w-md rounded-2xl border ${t.panel} ${t.surfaceSolid} p-6 shadow-2xl flex flex-col gap-4`}>
        <div className="flex items-start justify-between border-b pb-3 border-slate-800">
          <div>
            <h3 className={`text-base font-bold ${t.textPrimary}`}>Assign Field Inspector</h3>
            <p className={`text-xs ${t.textMuted} mt-0.5`}>
              Claim: <span className="font-mono text-cyan-400">{claim.id}</span> ({claim.fieldId})
            </p>
          </div>
          <button onClick={onClose} className="p-1 rounded-lg hover:bg-slate-800 text-slate-400">
            <X size={16} />
          </button>
        </div>

        <div className="space-y-2 max-h-72 overflow-y-auto">
          {officers.map((off) => (
            <div
              key={off.id}
              onClick={() => onAssignOfficer(claim.id, off.name)}
              className="p-3 rounded-xl border border-slate-800 hover:border-cyan-400/50 bg-slate-900/50 hover:bg-cyan-400/[0.05] transition-all cursor-pointer flex items-center justify-between"
            >
              <div className="space-y-0.5">
                <p className="text-xs font-bold text-slate-100">{off.name}</p>
                <p className="text-[11px] text-slate-400">{off.zone}</p>
                <span className="inline-block text-[10px] text-emerald-400 font-mono">
                  {off.activeClaimsCount} active task(s) assigned
                </span>
              </div>
              <button className="px-2.5 py-1 rounded-md bg-cyan-400/10 border border-cyan-400/30 text-cyan-300 text-xs font-semibold hover:bg-cyan-400/20">
                Assign
              </button>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Field Officers View (Nav Tab #2)
// ---------------------------------------------------------------------------

function FieldOfficersView({ officers }) {
  const t = useTheme();
  const [selectedZone, setSelectedZone] = useState("All");

  const zones = ["All", "Karnal North Zone", "Indore West Zone", "Punjab Central Belt", "Nashik Agricultural Zone"];

  const filteredOfficers = selectedZone === "All"
    ? officers
    : officers.filter((o) => o.zone === selectedZone);

  return (
    <div className="space-y-6">
      <GlassPanel className="p-5 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <Users className="text-cyan-400" size={20} />
            <h2 className={`text-lg font-bold ${t.textPrimary}`}>Field Officers Roster</h2>
          </div>
          <p className={`text-xs ${t.textFaint} mt-0.5`}>
            Regional inspectors, assigned zones &amp; ground inspection telemetry
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Filter size={14} className={t.textFaint} />
          <select
            value={selectedZone}
            onChange={(e) => setSelectedZone(e.target.value)}
            className={`px-3 py-1.5 rounded-lg border ${t.border} ${t.surfaceSolid} text-xs ${t.inputText} focus:outline-none focus:border-cyan-400`}
          >
            {zones.map((z) => (
              <option key={z} value={z}>{z}</option>
            ))}
          </select>
        </div>
      </GlassPanel>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
        {filteredOfficers.map((off) => (
          <GlassPanel key={off.id} className="p-5 flex flex-col justify-between gap-4 hover:border-cyan-400/40 transition-colors">
            <div className="space-y-3">
              <div className="flex items-start justify-between">
                <div className="w-10 h-10 rounded-full bg-gradient-to-br from-cyan-400 to-emerald-500 flex items-center justify-center font-bold text-slate-950 text-sm">
                  {off.name.split(" ").map((n) => n[0]).join("")}
                </div>
                <span className="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-400/10 border border-emerald-400/30 text-emerald-400">
                  {off.status}
                </span>
              </div>

              <div>
                <h3 className={`text-sm font-bold ${t.textPrimary}`}>{off.name}</h3>
                <p className={`text-xs ${t.textMuted} flex items-center gap-1 mt-0.5`}>
                  <MapPin size={11} className="text-cyan-400" />
                  {off.zone}
                </p>
              </div>

              <div className="pt-2 border-t border-slate-800 space-y-1 text-xs">
                <div className="flex items-center gap-2 text-slate-400">
                  <Mail size={12} />
                  <span className="truncate">{off.email}</span>
                </div>
                <div className="flex items-center gap-2 text-slate-400">
                  <Phone size={12} />
                  <span>{off.phone}</span>
                </div>
              </div>
            </div>

            <div className="pt-3 border-t border-slate-800 grid grid-cols-2 gap-2 text-center text-xs">
              <div className="p-2 rounded-lg bg-slate-900/60 border border-slate-800">
                <p className="text-cyan-400 font-bold text-base">{off.activeClaimsCount}</p>
                <p className="text-[10px] text-slate-500">Active Claims</p>
              </div>
              <div className="p-2 rounded-lg bg-slate-900/60 border border-slate-800">
                <p className="text-emerald-400 font-bold text-base">{off.totalVerified}</p>
                <p className="text-[10px] text-slate-500">Verified Total</p>
              </div>
            </div>
          </GlassPanel>
        ))}
      </div>
    </div>
  );
}

// ---------------------------------------------------------------------------
// Farmers Registry View (Nav Tab #3)
// ---------------------------------------------------------------------------

function FarmersView({ farmers }) {
  const t = useTheme();
  const [search, setSearch] = useState("");
  const [selectedFarmer, setSelectedFarmer] = useState(null);

  const filteredFarmers = farmers.filter(
    (f) =>
      f.name.toLowerCase().includes(search.toLowerCase()) ||
      f.fieldAddress.toLowerCase().includes(search.toLowerCase()) ||
      f.crop.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="space-y-6">
      <GlassPanel className="p-5 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <Leaf className="text-emerald-400" size={20} />
            <h2 className={`text-lg font-bold ${t.textPrimary}`}>Insured Farmers Registry</h2>
          </div>
          <p className={`text-xs ${t.textFaint} mt-0.5`}>
            Policy details, land acreage, coordinates &amp; insurance payout records
          </p>
        </div>

        <div className="relative w-full md:w-72">
          <Search size={14} className={`absolute left-3 top-1/2 -translate-y-1/2 ${t.textFaint}`} />
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Search farmer name or address..."
            className={`w-full pl-8 pr-3 py-1.5 rounded-lg ${t.surfaceSolid} border ${t.border} text-xs ${t.inputText} ${t.placeholder} focus:outline-none focus:border-emerald-400/60`}
          />
        </div>
      </GlassPanel>

      <GlassPanel className="overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className={`border-b ${t.innerBorder} ${t.surfaceSolid} ${t.textFaint} font-semibold uppercase tracking-wider text-[10px]`}>
                <th className="p-4">Farmer Name</th>
                <th className="p-4">Field Khasra &amp; Address</th>
                <th className="p-4">Crop Type</th>
                <th className="p-4">Area (Acres)</th>
                <th className="p-4">Policy Status</th>
                <th className="p-4">Total Payout</th>
                <th className="p-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody className={`divide-y ${t.divide}`}>
              {filteredFarmers.map((f) => (
                <tr key={f.id} className={`${t.rowHover} transition-colors`}>
                  <td className="p-4 font-bold text-slate-100">
                    <div>{f.name}</div>
                    <div className="text-[10px] font-normal text-slate-400">{f.phone}</div>
                  </td>
                  <td className="p-4 text-slate-300 max-w-xs truncate">{f.fieldAddress}</td>
                  <td className="p-4">
                    <span className="px-2 py-0.5 rounded-md bg-emerald-400/10 border border-emerald-400/30 text-emerald-300 font-semibold">
                      {f.crop}
                    </span>
                  </td>
                  <td className="p-4 text-slate-300 font-mono">{f.areaAcres} acres</td>
                  <td className="p-4">
                    <span className="px-2 py-0.5 rounded-full bg-cyan-400/10 border border-cyan-400/30 text-cyan-300 font-medium">
                      {f.policyStatus}
                    </span>
                  </td>
                  <td className="p-4 text-emerald-400 font-mono font-bold">${f.totalPayout.toLocaleString()}</td>
                  <td className="p-4 text-right">
                    <button
                      onClick={() => setSelectedFarmer(f)}
                      className="px-2.5 py-1 rounded-md border border-slate-700 hover:border-cyan-400 text-slate-300 hover:text-cyan-300 transition-colors"
                    >
                      View Telemetry
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </GlassPanel>

      {selectedFarmer && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-950/80 backdrop-blur-sm">
          <div className={`w-full max-w-lg rounded-2xl border ${t.panel} ${t.surfaceSolid} p-6 shadow-2xl space-y-4`}>
            <div className="flex items-start justify-between border-b pb-3 border-slate-800">
              <div>
                <h3 className="text-base font-bold text-slate-100">{selectedFarmer.name}</h3>
                <p className="text-xs text-slate-400">{selectedFarmer.fieldAddress}</p>
              </div>
              <button onClick={() => setSelectedFarmer(null)} className="p-1 text-slate-400 hover:text-slate-200">
                <X size={16} />
              </button>
            </div>

            <div className="space-y-3 text-xs text-slate-300">
              <div className="p-3 rounded-lg bg-slate-900 border border-slate-800 space-y-1 font-mono">
                <p>Latitude: <span className="text-cyan-400">{selectedFarmer.latitude}</span></p>
                <p>Longitude: <span className="text-cyan-400">{selectedFarmer.longitude}</span></p>
                <p>Selected Crop: <span className="text-emerald-400">{selectedFarmer.crop}</span></p>
              </div>

              <div className="p-3 rounded-lg bg-emerald-950/40 border border-emerald-800/40 space-y-1">
                <p className="font-bold text-emerald-300 flex items-center gap-1.5">
                  <Satellite size={14} />
                  Copernicus Sentinel-2B Live NDVI Telemetry
                </p>
                <p className="text-[11px] text-slate-300">Pre-Disaster Canopy Index: <strong>0.78</strong> (Healthy)</p>
                <p className="text-[11px] text-slate-300">Post-Disaster Canopy Index: <strong>0.41</strong> (Loss Detected)</p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

// ---------------------------------------------------------------------------
// Root Workspace Component
// ---------------------------------------------------------------------------

function DashboardBody({
  activeTab,
  claims,
  officers,
  farmers,
  onReview,
  onAssign,
  searchQuery,
  setSearchQuery,
}) {
  return (
    <>
      {activeTab === "Dashboard" && (
        <div className="grid grid-cols-1 lg:grid-cols-10 gap-6 items-start">
          <div className="lg:col-span-7 flex flex-col gap-6">
            <MetricsRow pendingCount={claims.filter((c) => c.status === "Pending").length} />
            <div className="min-h-[560px]">
              <LeafletMapPanel searchQuery={searchQuery} setSearchQuery={setSearchQuery} farmers={farmers} />
            </div>
          </div>

          <div className="lg:col-span-3">
            <div className="lg:sticky lg:top-20 min-h-[560px]">
              <ClaimsFeed claims={claims} onReview={onReview} onAssign={onAssign} />
            </div>
          </div>
        </div>
      )}

      {activeTab === "Field Officers" && (
        <FieldOfficersView officers={officers} />
      )}

      {activeTab === "Farmers" && (
        <FarmersView farmers={farmers} />
      )}
    </>
  );
}

export default function AeroCropDashboard() {
  const [activeTab, setActiveTab] = useState("Dashboard");
  const [darkMode, setDarkMode] = useState(true);

  const [claims, setClaims] = useState(INITIAL_CLAIMS);
  const [officers, setOfficers] = useState(INITIAL_OFFICERS);
  const [farmers, setFarmers] = useState(INITIAL_FARMERS);

  const [searchQuery, setSearchQuery] = useState("");
  const [reviewingClaim, setReviewingClaim] = useState(null);
  const [assigningClaim, setAssigningClaim] = useState(null);

  useEffect(() => {
    async function fetchBackendData() {
      try {
        const resClaims = await fetch("http://localhost:8000/api/v1/admin/claims");
        if (resClaims.ok) {
          const data = await resClaims.json();
          if (data.claims) setClaims(data.claims);
        }

        const resOff = await fetch("http://localhost:8000/api/v1/admin/officers");
        if (resOff.ok) {
          const data = await resOff.json();
          if (data.officers) setOfficers(data.officers);
        }

        const resFar = await fetch("http://localhost:8000/api/v1/admin/farmers");
        if (resFar.ok) {
          const data = await resFar.json();
          if (data.farmers) setFarmers(data.farmers);
        }
      } catch (e) {
        // Standalone fallback
      }
    }
    fetchBackendData();
  }, []);

  const handleUpdateStatus = async (claimId, newStatus, remarks, payout) => {
    setClaims((prev) =>
      prev.map((c) =>
        c.id === claimId
          ? { ...c, status: newStatus, officerNotes: remarks, estimatedPayout: payout }
          : c
      )
    );
    setReviewingClaim(null);

    try {
      await fetch("http://localhost:8000/api/v1/admin/claims/review", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          claim_id: claimId,
          status: newStatus,
          remarks: remarks,
          estimated_payout: payout,
        }),
      });
    } catch (e) {}
  };

  const handleAssignOfficer = async (claimId, officerName) => {
    setClaims((prev) =>
      prev.map((c) =>
        c.id === claimId ? { ...c, assignedOfficer: officerName } : c
      )
    );
    setAssigningClaim(null);

    try {
      await fetch("http://localhost:8000/api/v1/admin/claims/assign", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          claim_id: claimId,
          officer_id: officerName,
          officer_name: officerName,
        }),
      });
    } catch (e) {}
  };

  const filteredClaims = claims.filter(
    (c) =>
      c.farmer.toLowerCase().includes(searchQuery.toLowerCase()) ||
      c.fieldId.toLowerCase().includes(searchQuery.toLowerCase()) ||
      c.crop.toLowerCase().includes(searchQuery.toLowerCase()) ||
      c.reason.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <ThemeContext.Provider value={darkMode}>
      <div
        className={`min-h-screen w-full antialiased selection:bg-cyan-400/30 transition-colors duration-300 ${
          darkMode ? "bg-slate-950 text-slate-100" : "bg-slate-50 text-slate-900"
        }`}
        style={{
          backgroundImage: darkMode
            ? "radial-gradient(ellipse 80% 50% at 20% -10%, rgba(0,240,255,0.06), transparent), radial-gradient(ellipse 60% 40% at 90% 10%, rgba(16,224,160,0.05), transparent)"
            : "radial-gradient(ellipse 80% 50% at 20% -10%, rgba(0,180,255,0.05), transparent), radial-gradient(ellipse 60% 40% at 90% 10%, rgba(16,224,160,0.05), transparent)",
        }}
      >
        <TopNav
          activeTab={activeTab}
          setActiveTab={setActiveTab}
          darkMode={darkMode}
          setDarkMode={setDarkMode}
        />

        <main className="max-w-[1600px] mx-auto px-5 py-6">
          <DashboardBody
            activeTab={activeTab}
            claims={filteredClaims}
            officers={officers}
            farmers={farmers}
            onReview={(claim) => setReviewingClaim(claim)}
            onAssign={(claim) => setAssigningClaim(claim)}
            searchQuery={searchQuery}
            setSearchQuery={setSearchQuery}
          />
        </main>

        <footer className="max-w-[1600px] mx-auto px-5 pb-6 pt-2 flex items-center justify-between text-[11px] text-slate-500 dark:text-slate-600">
          <span>AERO-CROP Admin HUD · Build 1.0.0</span>
          <span className="flex items-center gap-1.5">
            <Radio size={11} className="text-emerald-500 dark:text-emerald-400" />
            All systems nominal
          </span>
        </footer>

        {reviewingClaim && (
          <ReviewClaimModal
            claim={reviewingClaim}
            onClose={() => setReviewingClaim(null)}
            onUpdateStatus={handleUpdateStatus}
          />
        )}

        {assigningClaim && (
          <AssignOfficerModal
            claim={assigningClaim}
            officers={officers}
            onClose={() => setAssigningClaim(null)}
            onAssignOfficer={handleAssignOfficer}
          />
        )}
      </div>
    </ThemeContext.Provider>
  );
}
