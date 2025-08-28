# Northern Colorado Builder Directory - Product Requirements Document

## Table of Contents
1. [Executive Summary](#executive-summary)
2. [Product Overview](#product-overview)
3. [User Stories & Personas](#user-stories--personas)
4. [Core Features](#core-features)
5. [Technical Architecture](#technical-architecture)
6. [Data Models](#data-models)
7. [User Experience & Flow](#user-experience--flow)
8. [Integrations](#integrations)
9. [Business Logic](#business-logic)
10. [Performance Requirements](#performance-requirements)
11. [Security & Compliance](#security--compliance)
12. [Future Roadmap](#future-roadmap)

---

## Executive Summary

**Product Name:** NoCo New Builds - Northern Colorado Builder Directory  
**Version:** 0.1.2  
**Industry:** Real Estate Technology / PropTech  
**Target Market:** Northern Colorado Home Buyers  
**Business Model:** Lead Generation Platform for Real Estate Professionals  

### Vision Statement
To be the definitive resource for Northern Colorado home buyers to discover, compare, and connect with new home builders, while generating qualified leads for real estate professionals.

### Key Value Propositions
- **For Home Buyers:** Comprehensive builder comparison, incentive tracking, and geographic visualization
- **For Real Estate Agents:** Qualified lead capture and customer relationship management integration
- **For Builders:** Exposure to active home buyers in the Northern Colorado market

---

## Product Overview

### Primary Objectives
1. **Lead Generation:** Capture and qualify potential home buyer leads through user registration
2. **Builder Discovery:** Help users find and compare new home builders in Northern Colorado
3. **Market Intelligence:** Provide current incentive information and builder data
4. **Geographic Context:** Visualize builders and communities on interactive maps

### Success Metrics
- **Lead Quality:** User registration completion rate >85%
- **Engagement:** Average session duration >3 minutes
- **Conversion:** Builder contact/inquiry rate >15%
- **Retention:** Return user rate >40%

---

## User Stories & Personas

### Primary Persona: First-Time Home Buyer
**Demographics:** Age 25-35, Household Income $70K-$120K, Tech-savvy  
**Goals:** Find affordable builders, understand options, compare pricing  
**Pain Points:** Information overload, lack of transparency, complex processes

**User Stories:**
- As a first-time buyer, I want to compare builders by price range so I can find options within my budget
- As a user, I want to see builder locations on a map so I can understand proximity to work/amenities
- As a buyer, I want to track current incentives so I don't miss savings opportunities

### Secondary Persona: Move-Up Buyer
**Demographics:** Age 35-50, Household Income $100K-$200K, Quality-focused  
**Goals:** Find luxury/custom builders, specific community features, upgrade lifestyle  
**Pain Points:** Limited high-end options, community amenities information

### Tertiary Persona: Real Estate Agent
**Demographics:** Licensed professionals serving Northern Colorado  
**Goals:** Generate buyer leads, provide client value, stay informed on market  
**Pain Points:** Lead quality, follow-up systems, market knowledge currency

---

## Core Features

### 1. User Registration & Authentication System
**Status:** ✅ Implemented  
**Components:**
- App-wide registration gate (blocks all access until registration)
- Clerk.dev authentication integration
- Required fields: First Name, Last Name, Email
- Automatic CRM lead generation via Resend email service
- User profile management

**Technical Implementation:**
- `UserRegistrationGate` component in main layout
- Clerk user management with profile completion validation
- Automated email notifications to `leads+remaxalliance7774-a-1405348@kvcore.com`

### 2. Builder Directory & Search
**Status:** ✅ Implemented  
**Components:**
- Comprehensive builder database (46+ builders)
- Advanced search with multiple filters
- Builder comparison functionality
- Detailed builder profiles with logos and information

**Search Capabilities:**
- Text search across builder names and descriptions
- Filter by: Location, Price Range, Home Types, Builder Categories
- Sort by: Name, Rating, Price (Low-High, High-Low)
- City-specific filtering

**Builder Information Includes:**
- Basic info (name, description, contact details)
- Pricing ranges and home types offered
- Communities and locations served
- Specialties and building styles
- Corporate information and ratings

### 3. Geographic Visualization
**Status:** ✅ Implemented  
**Components:**
- Interactive Google Maps integration
- Builder/community location plotting
- Geographic filtering and exploration
- Location-based search capabilities

**Technical Implementation:**
- Google Maps API integration
- Coordinate-based community mapping
- Interactive markers with builder details

### 4. Incentives & Promotions Tracking
**Status:** ✅ Implemented  
**Components:**
- Real-time incentive database
- Builder-specific promotions
- Financing offers and rebate tracking
- Expiration date management

**Incentive Types:**
- Special financing rates
- Closing cost credits
- Rebates and discounts
- Limited-time promotions

### 5. Builder Comparison System
**Status:** ✅ Implemented  
**Components:**
- Multi-builder selection interface
- Side-by-side comparison tables
- Comparison history tracking
- Saved comparisons for registered users

**Comparison Features:**
- Select up to multiple builders simultaneously
- Detailed comparison across all attributes
- Export/share comparison results
- Saved comparison persistence

### 6. Lead Tracking & Analytics
**Status:** ✅ Implemented  
**Components:**
- Supabase integration for lead data
- User behavior tracking
- Interaction analytics
- CRM integration pipeline

**Tracked Events:**
- User registration and profile completion
- Builder interactions and views
- Comparison activities
- Geographic exploration patterns

### 7. PWA & Mobile Optimization
**Status:** ✅ Implemented  
**Components:**
- Progressive Web App manifest
- Mobile-responsive design
- Installation prompts
- Offline capabilities consideration

---

## Technical Architecture

### Frontend Stack
- **Framework:** Next.js 15.5.0 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **UI Components:** Custom component library with Lucide React icons
- **State Management:** React hooks and context

### Backend Stack
- **Runtime:** Node.js with Next.js API routes
- **Database:** Supabase (PostgreSQL)
- **Authentication:** Clerk.dev
- **Email Service:** Resend
- **File Storage:** Next.js static assets

### Infrastructure
- **Hosting:** Vercel
- **CDN:** Vercel Edge Network
- **Monitoring:** Vercel Speed Insights
- **Environment:** Production on Vercel, Development local

### External APIs
- **Google Maps API:** Geographic visualization and location services
- **Clerk API:** User authentication and profile management
- **Supabase API:** Database operations and real-time features
- **Resend API:** Transactional email delivery

---

## Data Models

### Builder Entity
```typescript
interface Builder {
  id: string;                          // Unique identifier
  name: string;                        // Builder company name
  description: string;                 // Company description
  location: string;                    // Primary service location
  category: BuilderCategory;           // National/Regional/Local Custom
  builderType: BuilderType[];          // Production/Luxury/Semi-Custom/Custom/Townhomes
  priceRange: { min: number; max: number; };
  rating: number;                      // 1-5 star rating
  reviewCount: number;                 // Number of reviews
  specialties: string[];               // Key specialties/features
  imageUrl: string;                    // Hero image URL
  logoUrl?: string;                    // Company logo URL
  website?: string;                    // Official website
  phone?: string;                      // Contact phone
  email?: string;                      // Contact email
  communities: CommunityDetails[];     // Associated communities
  warranty?: string;                   // Warranty information
  squareFootageRange?: { min: number; max: number; };
  established?: string;                // Year established
  buildingStyles?: string[];           // Architectural styles offered
  currentIncentives?: string;          // Active promotions
  buildOnYourLot?: boolean;           // Offers BYOL service
  yearlyHomes?: number;               // Annual construction volume
  servesCounties?: string[];          // Service area counties
  corporateInfo?: {                   // Corporate details
    headquarters?: string;
    founded?: string;
    publicCompany?: boolean;
    stockTicker?: string;
  };
}
```

### Community Entity
```typescript
interface CommunityDetails {
  id: string;                          // Unique identifier
  name: string;                        // Community name
  city: string;                        // City location
  status: CommunityStatus;             // Active/Coming Soon/Final Phase/Sold Out/Pre-Sales
  homeTypes: HomeType[];               // Available home types
  priceRange?: { min: number; max: number; };
  squareFootageRange?: { min: number; max: number; };
  url?: string;                        // Community website
  description?: string;                // Community description
  collections?: string[];              // Floor plan collections
  launchDate?: string;                 // Launch date
  amenities?: string[];                // Community amenities
  lotSizes?: string;                   // Available lot sizes
  nearbyAttractions?: string[];        // Local attractions
  coordinates?: { lat: number; lng: number; };  // Map coordinates
}
```

### Incentive Entity
```typescript
interface Incentive {
  id: string;                          // Unique identifier
  title: string;                       // Promotion title
  description: string;                 // Detailed description
  type: 'rebate' | 'tax_credit' | 'discount' | 'financing';  // Incentive type
  amount: number;                      // Dollar amount
  percentage?: number;                 // Percentage value
  eligibility: string[];               // Eligibility requirements
  expirationDate?: string;             // Expiration date
  provider: string;                    // Builder/provider name
  category: string;                    // Incentive category
  location: string;                    // Geographic applicability
}
```

### Database Schema (Supabase)
```sql
-- Lead tracking tables
CREATE TABLE leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clerk_user_id TEXT UNIQUE NOT NULL,
    email TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    phone TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE lead_interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_id UUID REFERENCES leads(id) ON DELETE CASCADE,
    interaction_type TEXT NOT NULL,
    builder_id TEXT,
    community_id TEXT,
    metadata JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE saved_builders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_id UUID REFERENCES leads(id) ON DELETE CASCADE,
    builder_id TEXT NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE comparison_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lead_id UUID REFERENCES leads(id) ON DELETE CASCADE,
    builder_ids TEXT[] NOT NULL,
    criteria JSONB,
    name TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

---

## User Experience & Flow

### Registration Flow
1. **Landing Page:** User attempts to access any page
2. **Registration Gate:** App-wide redirect to registration form
3. **Authentication:** Sign up/in via Clerk (email, social, etc.)
4. **Profile Completion:** Required fields collection (name, email)
5. **Lead Generation:** Automatic CRM notification
6. **App Access:** Full application functionality unlocked

### Builder Discovery Flow
1. **Directory View:** Grid of builder cards with key information
2. **Search & Filter:** Dynamic filtering by location, price, type
3. **Builder Details:** Detailed view with communities and information
4. **Comparison:** Multi-select for side-by-side comparison
5. **Contact:** Direct contact information and website links

### Geographic Exploration Flow
1. **Map View:** Interactive map with builder/community markers
2. **Location Search:** Geographic filtering and exploration
3. **Marker Details:** Popup information for locations
4. **Builder Navigation:** Deep links to builder details

### Incentive Discovery Flow
1. **Incentives Page:** Comprehensive list of current promotions
2. **Category Filtering:** Filter by incentive type and builder
3. **Expiration Tracking:** Time-sensitive promotion awareness
4. **Builder Connection:** Direct links to participating builders

---

## Integrations

### Authentication - Clerk.dev
**Purpose:** User registration, authentication, and profile management  
**Implementation:** 
- Frontend: `@clerk/nextjs` package
- Environment variables: `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`, `CLERK_SECRET_KEY`
- Features: Social login, email verification, user profiles

### Database - Supabase
**Purpose:** Lead tracking, analytics, and data persistence  
**Implementation:**
- Client: `@supabase/supabase-js`
- Environment variables: `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- Features: Real-time data, user analytics, lead management

### Email - Resend
**Purpose:** CRM lead notifications and transactional emails  
**Implementation:**
- API: `resend` package
- Environment variable: `RESEND_API_KEY`
- Target: `leads+remaxalliance7774-a-1405348@kvcore.com`
- Features: HTML email templates, delivery tracking

### Maps - Google Maps
**Purpose:** Geographic visualization and location services  
**Implementation:**
- API: `@googlemaps/js-api-loader`
- Environment variable: `NEXT_PUBLIC_GOOGLE_MAPS_API_KEY`
- Features: Interactive maps, geocoding, location plotting

### Analytics - Vercel Speed Insights
**Purpose:** Performance monitoring and optimization  
**Implementation:**
- Package: `@vercel/speed-insights`
- Features: Core Web Vitals tracking, performance analytics

---

## Business Logic

### Lead Qualification Logic
```typescript
// User is considered qualified lead when:
const isQualifiedLead = (user: User) => {
  return (
    user.firstName && 
    user.lastName && 
    user.primaryEmailAddress?.emailAddress &&
    user.isSignedIn
  );
};
```

### Builder Filtering Logic
```typescript
// Multi-dimensional filtering system
const filterBuilders = (builders: Builder[], filters: FilterState) => {
  return builders.filter(builder => {
    // Location filtering
    if (filters.location && !builder.location.includes(filters.location)) return false;
    
    // Price range filtering
    const [minPrice, maxPrice] = filters.priceRange;
    if (builder.priceRange.max < minPrice || builder.priceRange.min > maxPrice) return false;
    
    // Category filtering
    if (filters.categories.length > 0 && !filters.categories.includes(builder.category)) return false;
    
    // Builder type filtering
    if (filters.builderTypes.length > 0) {
      const hasMatchingType = filters.builderTypes.some(type => 
        builder.builderType.includes(type)
      );
      if (!hasMatchingType) return false;
    }
    
    // Home type filtering
    if (filters.homeTypes.length > 0) {
      const hasMatchingHomeType = builder.communities.some(community =>
        community.homeTypes.some(homeType => 
          filters.homeTypes.includes(homeType)
        )
      );
      if (!hasMatchingHomeType) return false;
    }
    
    return true;
  });
};
```

### Lead Tracking Logic
```typescript
// Automatic lead tracking on user interactions
const trackUserInteraction = async (type: InteractionType, metadata?: any) => {
  if (!isSignedIn || !user) return;
  
  await LeadService.trackInteraction(leadId, {
    type,
    builderId: metadata?.builderId,
    communityId: metadata?.communityId,
    metadata,
    userAgent: navigator.userAgent,
    timestamp: new Date().toISOString()
  });
};
```

---

## Performance Requirements

### Core Web Vitals Targets
- **Largest Contentful Paint (LCP):** < 2.5s
- **First Input Delay (FID):** < 100ms
- **Cumulative Layout Shift (CLS):** < 0.1

### Load Time Requirements
- **Initial Page Load:** < 3s on 3G connection
- **Search Results:** < 1s response time
- **Map Loading:** < 2s for initial render
- **Image Loading:** Progressive loading with placeholders

### Scalability Requirements
- **Concurrent Users:** Support 1,000+ simultaneous users
- **Database Performance:** < 100ms query response times
- **CDN Coverage:** Global edge distribution via Vercel

---

## Security & Compliance

### Data Protection
- **User Data:** Encrypted at rest and in transit
- **Authentication:** OAuth 2.0 via Clerk with secure session management
- **API Security:** Rate limiting and request validation
- **Environment Variables:** Secure secret management

### Privacy Compliance
- **Data Collection:** Transparent consent for lead generation
- **Data Usage:** Clear privacy policy and terms of service
- **Data Retention:** Configurable retention policies
- **User Rights:** Data access and deletion capabilities

### Security Measures
- **HTTPS:** Enforced SSL/TLS encryption
- **Input Validation:** Comprehensive form and API validation
- **XSS Protection:** Content Security Policy implementation
- **CSRF Protection:** Built-in Next.js CSRF protection

---

## Future Roadmap

### Phase 2: Enhanced Features (Q2 2025)
- **Advanced Search:** AI-powered builder recommendations
- **Virtual Tours:** 3D community and home tours
- **Mortgage Calculator:** Integrated financing tools
- **Builder Reviews:** User-generated reviews and ratings
- **Mobile App:** Native iOS/Android applications

### Phase 3: Platform Expansion (Q3 2025)
- **Geographic Expansion:** Denver Metro, Colorado Springs
- **Builder Portal:** Self-service builder profile management
- **Agent Dashboard:** Dedicated real estate agent interface
- **API Platform:** Public API for third-party integrations

### Phase 4: Advanced Intelligence (Q4 2025)
- **Market Analytics:** Price trend analysis and forecasting
- **Personalization:** AI-driven builder recommendations
- **Automated Matching:** Smart buyer-builder matching
- **Community Insights:** Demographic and lifestyle matching

---

## Technical Specifications

### Development Environment
- **Node.js Version:** 18.x or higher
- **Package Manager:** npm
- **Development Server:** Next.js dev server with hot reloading
- **Build System:** Next.js build with static optimization

### Production Environment
- **Hosting Platform:** Vercel with edge functions
- **Domain:** Custom domain with SSL certificate
- **CDN:** Global edge distribution
- **Database:** Supabase managed PostgreSQL
- **Monitoring:** Vercel Analytics and Speed Insights

### Code Quality
- **TypeScript:** Strict type checking enabled
- **ESLint:** Next.js recommended configuration
- **Code Formatting:** Prettier integration
- **Git Hooks:** Pre-commit linting and formatting

---

## Deployment & Operations

### Deployment Pipeline
1. **Development:** Local development with hot reloading
2. **Staging:** Automated deployment on feature branch push
3. **Production:** Deployment on main branch merge
4. **Rollback:** Quick rollback capability via Vercel

### Environment Management
- **Development:** `.env.local` with development keys
- **Production:** Vercel environment variables with production keys
- **Staging:** Separate staging environment configuration

### Monitoring & Alerting
- **Performance:** Vercel Speed Insights monitoring
- **Errors:** Built-in error tracking and logging
- **Uptime:** Automated uptime monitoring
- **Analytics:** User behavior and conversion tracking

---

*This PRD represents the current state and future vision of the NoCo New Builds platform. It should be reviewed and updated quarterly to reflect product evolution and market changes.*

**Last Updated:** August 26, 2025  
**Version:** 1.0  
**Next Review:** November 26, 2025