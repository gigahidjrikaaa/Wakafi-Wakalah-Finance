'use client'
import React, { useState } from 'react';
import Link from 'next/link';
// Import icons from lucide-react
import { Wallet, Download, TrendingUp, Award, Star, ChevronDown, ChevronUp, CheckCircle, Facebook, Twitter, Linkedin, Mail, ExternalLink } from 'lucide-react';
import { ConnectButton } from '@rainbow-me/rainbowkit';
// --- Reusable Components ---

// Button Component
const Button = ({ children, variant = 'primary', className = '', ...props }) => {
  const baseStyle = 'px-6 py-3 rounded-lg font-semibold transition duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-offset-2';
  const variants = {
    primary: 'bg-green-600 text-white hover:bg-green-700 focus:ring-green-500',
    secondary: 'bg-gray-100 text-gray-700 hover:bg-gray-200 focus:ring-gray-500',
    outline: 'border border-green-600 text-green-600 hover:bg-green-50 focus:ring-green-500',
    link: 'text-green-600 hover:text-green-700 underline',
  };
  return (
    <button className={`${baseStyle} ${variants[variant]} ${className}`} {...props}>
      {children}
    </button>
  );
};

// Card Component
const Card = ({ children, className = '', ...props }) => {
  return (
    <div className={`bg-white rounded-xl shadow-soft p-6 ${className}`} {...props}>
      {children}
    </div>
  );
};

// --- Section Components ---

// Header Component
const Header = () => (
  <header className="sticky top-0 z-50 bg-white/80 backdrop-blur-md shadow-sm">
    <nav className="container mx-auto px-6 py-4 flex justify-between items-center">
      {/* Logo */}
      <div className="text-2xl font-bold text-green-700">
        Wakafi
      </div>
      {/* Connect Wallet Button */}
      {/* <Button variant="primary" className="hidden md:inline-flex items-center gap-2">
        <Wallet size={18} /> Connect Wallet
      </Button> */}
      <ConnectButton/>
       {/* Mobile Menu Button (optional - for future expansion) */}
       <button className="md:hidden text-gray-600 hover:text-green-600">
         <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth={1.5} stroke="currentColor" className="w-6 h-6">
           <path strokeLinecap="round" strokeLinejoin="round" d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5" />
         </svg>
       </button>
    </nav>
  </header>
);

// Hero Section Component
const HeroSection = () => (
  <section className="bg-gradient-to-b from-white to-green-50 py-20 md:py-32">
    <div className="container mx-auto px-6 text-center">
      {/* Headline */}
      <h1 className="text-4xl md:text-6xl font-bold text-gray-800 mb-4 leading-tight">
        Halal Investment, <span className="text-green-600">Without Usury</span>
      </h1>
      {/* Subheadline */}
      <p className="text-lg md:text-xl text-gray-600 mb-8 max-w-2xl mx-auto">
      Wakafi (Wakalah Finance) is a sharia-based DeFi platform that manages your funds safely and ethically, according to the principles of Wakalah bil Istithmar.
      </p>
      {/* CTA Button */}
      <Button variant="primary" className="px-8 py-4 text-lg inline-flex items-center gap-2 cursor-pointer">
         <Link href="/dashboard">
            Start Investing
         </Link>
      </Button>
    </div>
  </section>
);

// How It Works Section Component
const HowItWorksSection = () => {
  const steps = [
    { icon: Wallet, title: 'Connect Wallet', description: 'Securely connect your preferred Web3 wallet in seconds.' },
    { icon: Download, title: 'Deposit Funds', description: 'Easily deposit stablecoins or other supported assets.' },
    { icon: TrendingUp, title: 'Sharia Investment', description: 'Funds are managed by the protocol to halal-verified assets.' },
    { icon: Award, title: 'Receive Profit', description: 'Get the net return on investment after deducting Ujrah (fee).' },
  ];

  return (
    <section className="py-16 md:py-24 bg-white" id='how-it-works'>
      <div className="container mx-auto px-6">
        <h2 className="text-3xl md:text-4xl font-bold text-center text-gray-800 mb-12">
          How Wakafi Works
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {steps.map((step, index) => (
            <div key={index} className="text-center p-6 border border-gray-100 rounded-xl hover:shadow-lg transition duration-300">
              <div className="inline-flex items-center justify-center w-16 h-16 mb-4 rounded-full bg-green-100 text-green-600">
                <step.icon size={32} />
              </div>
              <h3 className="text-xl font-semibold text-gray-800 mb-2">{step.title}</h3>
              <p className="text-gray-600">{step.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

// Portfolio Section Component
const PortfolioSection = () => {
  const products = [
    { name: 'Sukuk Fund I', apy: '5-7%', risk: 'Low', ujrah: '1.5%', description: 'Invest in diversified Sharia-compliant bonds.' },
    { name: 'Halal Equity Basket', apy: '8-12%', risk: 'Medium', ujrah: '2.0%', description: 'Access a curated selection of ethical stocks.' },
    { name: 'Murabaha Liquidity Pool', apy: '4-6%', risk: 'Low', ujrah: '1.0%', description: 'Provide liquidity for cost-plus financing deals.' },
    { name: 'Ijarah Real Estate Token', apy: '6-9%', risk: 'Medium', ujrah: '2.5%', description: 'Fractional ownership in Sharia-compliant rental properties.' },
  ];

  return (
    <section className="py-16 md:py-24 bg-gray-50">
      <div className="container mx-auto px-6">
        <h2 className="text-3xl md:text-4xl font-bold text-center text-gray-800 mb-12">
          Explore Halal Investments
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {products.map((product, index) => (
            <Card key={index} className="flex flex-col justify-between hover:scale-[1.02] transition duration-300">
              <div>
                <h3 className="text-xl font-semibold text-gray-800 mb-2">{product.name}</h3>
                <p className="text-gray-600 mb-4 text-sm">{product.description}</p>
                <div className="flex justify-between items-center mb-4 text-sm">
                  <span className="text-gray-500">Est. Historical APY</span>
                  <span className="font-semibold text-green-600">{product.apy}</span>
                </div>
                <div className="flex justify-between items-center mb-4 text-sm">
                  <span className="text-gray-500">Risk Level</span>
                  <span className={`font-medium px-2 py-0.5 rounded-full text-xs ${
                    product.risk === 'Low' ? 'bg-green-100 text-green-700' :
                    product.risk === 'Medium' ? 'bg-yellow-100 text-yellow-700' :
                    'bg-red-100 text-red-700' // Assuming High risk exists
                  }`}>{product.risk}</span>
                </div>
                <div className="flex justify-between items-center text-sm">
                  <span className="text-gray-500">Service Fee (Ujrah)</span>
                  <span className="font-semibold text-gray-700">{product.ujrah}</span>
                </div>
              </div>
              <Button variant="outline" className="mt-6 w-full">
                Learn More
              </Button>
            </Card>
          ))}
        </div>
      </div>
    </section>
  );
};

// Sharia Compliance Section Component
const ShariaComplianceSection = () => (
  <section className="py-16 md:py-24 bg-white" id='sharia-compliance'>
    <div className="container mx-auto px-6 flex flex-col md:flex-row items-center gap-12">
      {/* Badge and Quote */}
      <div className="md:w-1/2 text-center md:text-left">
        <div className="inline-flex items-center gap-2 bg-green-100 text-green-700 px-4 py-2 rounded-full mb-6 font-medium">
          <CheckCircle size={20} /> Sharia Verified
        </div>
        <h2 className="text-3xl md:text-4xl font-bold text-gray-800 mb-4">
          Committed to Compliance
        </h2>
        <blockquote className="text-lg text-gray-600 italic border-l-4 border-green-500 pl-4 mb-6">
          "Our investments adhere to the principles of Wakalah bil Istithmar, ensuring ethical and transparent operations under Sharia law."
        </blockquote>
        <a href="#fatwa-docs" className="inline-flex items-center gap-1 text-green-600 hover:text-green-700 font-medium group">
          View Fatwa Documents
          <ExternalLink size={16} className="group-hover:translate-x-1 transition-transform"/>
        </a>
      </div>
      {/* Illustration/Image Placeholder */}
      <div className="md:w-1/2 flex justify-center">
         {/* Placeholder for an illustration or image */}
         <div className="w-full max-w-md h-64 hidden bg-gradient-to-br from-green-100 to-green-200 rounded-lg lg:flex items-center justify-center text-green-500">
            <Award size={64} strokeWidth={1.5}/>
         </div>
      </div>
    </div>
  </section>
);

// Testimonials and Partners Section Component
const TestimonialsPartnersSection = () => {
  const testimonials = [
    { name: 'Ahmed K.', quote: 'Finally, a Web3 platform I can trust. Wakafi makes Halal investing easy and transparent.', rating: 5 },
    { name: 'Fatima Z.', quote: 'The yields are competitive, and knowing it\'s Sharia-compliant gives me peace of mind.', rating: 5 },
    { name: 'Yusuf A.', quote: 'Great UI/UX, seamless wallet connection. Impressed with the professionalism.', rating: 4 },
  ];
  // Placeholder logos - replace with actual SVGs or image tags
  const partners = ['PartnerLogo1', 'PartnerLogo2', 'PartnerLogo3', 'PartnerLogo4', 'PartnerLogo5'];

  return (
    <section className="py-16 md:py-24 bg-gray-50">
      <div className="container mx-auto px-6">
        {/* Testimonials */}
        <h2 className="text-3xl md:text-4xl font-bold text-center text-gray-800 mb-12">
          Trusted by Users
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-16">
          {testimonials.map((testimonial, index) => (
            <Card key={index}>
              <div className="flex mb-2">
                {[...Array(testimonial.rating)].map((_, i) => (
                  <Star key={i} size={18} className="text-yellow-400 fill-current" />
                ))}
                {[...Array(5 - testimonial.rating)].map((_, i) => (
                  <Star key={i} size={18} className="text-gray-300 fill-current" />
                ))}
              </div>
              <p className="text-gray-600 italic mb-4">"{testimonial.quote}"</p>
              <p className="font-semibold text-gray-800">{testimonial.name}</p>
            </Card>
          ))}
        </div>

        {/* Partners */}
        <h3 className="text-2xl font-semibold text-center text-gray-700 mb-8">
          Our Partners & Integrations
        </h3>
        <div className="flex flex-wrap justify-center items-center gap-8 md:gap-12 grayscale opacity-60">
          {partners.map((partner, index) => (
            // Replace with actual <img> or SVG components
            <div key={index} className="text-gray-500 text-sm font-medium h-8 flex items-center">
              {/* Placeholder SVG */}
              <svg className="h-8 w-auto" fill="currentColor" viewBox="0 0 120 30" xmlns="http://www.w3.org/2000/svg">
                <text x="60" y="20" textAnchor="middle" fontSize="14" fontFamily="Arial">{partner}</text>
              </svg>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

// FAQ Item Component
const FaqItem = ({ question, answer }) => {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <div className="border-b border-gray-200 py-4">
      <button
        className="flex justify-between items-center w-full text-left"
        onClick={() => setIsOpen(!isOpen)}
        aria-expanded={isOpen}
      >
        <span className="text-lg font-medium text-gray-800">{question}</span>
        {isOpen ? <ChevronUp size={20} className="text-green-600" /> : <ChevronDown size={20} className="text-gray-500" />}
      </button>
      {isOpen && (
        <div className="mt-3 text-gray-600">
          {answer}
        </div>
      )}
    </div>
  );
};


// FAQ Section Component
const FaqSection = () => {
  const faqs = [
    { question: 'Is Wakafi truly Sharia-compliant?', answer: 'Yes, all our investment strategies and operations are reviewed and approved by independent Sharia scholars. We operate primarily under the Wakalah bil Istithmar (investment agency) contract. You can view our Fatwa documentation for details.' },
    { question: 'What are the risks involved?', answer: 'Like all investments, DeFi involves risks, including smart contract vulnerabilities and market volatility. We mitigate risks through audits, diversified portfolios, and selecting established protocols, but potential loss of capital exists. We provide risk ratings for transparency.' },
    { question: 'What is "Ujrah"?', answer: 'Ujrah is the service fee charged by Wakafi for managing the investments on your behalf, as permitted under the Wakalah contract. It\'s calculated based on the assets under management and is clearly stated for each product.' },
    { question: 'Which wallets are supported?', answer: 'We support popular Web3 wallets like MetaMask, Trust Wallet, WalletConnect compatible wallets, and others. The connection process is standard and secure.' },
    { question: 'How are profits distributed?', answer: 'Profits generated from the underlying investments are distributed proportionally to investors after deducting the Ujrah, according to the terms agreed upon in the Wakalah contract.' },
  ];

  return (
    <section className="py-16 md:py-24 bg-white" id='faq'>
      <div className="container mx-auto px-6 max-w-3xl">
        <h2 className="text-3xl md:text-4xl font-bold text-center text-gray-800 mb-12">
          Frequently Asked Questions
        </h2>
        <div className="space-y-4">
          {faqs.map((faq, index) => (
            <FaqItem key={index} question={faq.question} answer={faq.answer} />
          ))}
        </div>
      </div>
    </section>
  );
};


// Footer Component
const Footer = () => (
  <footer className="bg-gray-900 text-gray-300 py-16">
    <div className="container mx-auto px-6">
      <div className="grid grid-cols-1 md:grid-cols-3 gap-12 mb-12">
        {/* Column 1: CTA and Contact */}
        <div>
          <h3 className="text-xl font-semibold text-white mb-4">Ready to Start?</h3>
          <p className="mb-6">Join Wakafi today and invest in your future, the Halal way.</p>
          <Button variant="primary" className="inline-flex items-center gap-2 mb-6 cursor-pointer">
            Start Investing
          </Button>
           <div className="flex items-center gap-2 text-sm hover:text-white">
             <Mail size={16} />
             <a href="mailto:support@wakafi.app">support@wakafi.app</a>
           </div>
        </div>

        {/* Column 2: Quick Links (Example) */}
        <div>
          <h4 className="text-lg font-semibold text-white mb-4">Quick Links</h4>
          <ul className="space-y-2 text-sm">
            <li><a href="#how-it-works" className="hover:text-white hover:underline">How It Works</a></li>
            <li><a href="#portfolio" className="hover:text-white hover:underline">Investments</a></li>
            <li><a href="#sharia-compliance" className="hover:text-white hover:underline">Sharia Compliance</a></li>
            <li><a href="#faq" className="hover:text-white hover:underline">FAQ</a></li>
          </ul>
        </div>

        {/* Column 3: Legal and Social */}
        <div>
          <h4 className="text-lg font-semibold text-white mb-4">Legal & Social</h4>
          <ul className="space-y-2 text-sm mb-6">
            <li><a href="#privacy" className="hover:text-white hover:underline">Privacy Policy</a></li>
            <li><a href="#terms" className="hover:text-white hover:underline">Terms of Service</a></li>
            <li><a href="#fatwa-docs" className="hover:text-white hover:underline">Fatwa Documents</a></li>
          </ul>
          <div className="flex space-x-4">
            <a href="#" className="hover:text-white"><Facebook size={20} /></a>
            <a href="#" className="hover:text-white"><Twitter size={20} /></a>
            <a href="#" className="hover:text-white"><Linkedin size={20} /></a>
          </div>
        </div>
      </div>

      {/* Bottom Bar */}
      <div className="border-t border-gray-700 pt-8 text-center text-sm text-gray-500">
        &copy; {new Date().getFullYear()} Wakafi Technologies. All Rights Reserved. <br />
        <span className="text-xs mt-1 block">Built with Islamic values for the modern investor.</span>
      </div>
    </div>
  </footer>
);


// --- Main App Component ---
export default function Home() {
  return (
    // Ensure you have Tailwind CSS set up in your Next.js project
    // Add a font link (e.g., Inter) in your _document.js or global CSS
    <div className="font-sans bg-white"> {/* Assuming 'font-sans' is configured for Inter/Poppins */}
      <Header />
      <main>
        <HeroSection />
        <HowItWorksSection />
        {/* <PortfolioSection /> */}
        <ShariaComplianceSection />
        {/* <TestimonialsPartnersSection /> */}
        <FaqSection />
      </main>
      <Footer />
    </div>
  );
}

// Add this CSS globally or via a CSS module for the soft shadow utility
/*
<style jsx global>{`
  .shadow-soft {
    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
  }
  .font-sans { /* Configure this in your tailwind.config.js */
    /* font-family: 'Inter', sans-serif; */ /* Example */
  /* }
`}</style>
*/

// Remember to install lucide-react: npm install lucide-react or yarn add lucide-react
// Ensure Tailwind CSS is properly configured in your Next.js project.
// You might need to configure the 'font-sans' utility in your tailwind.config.js
// to use 'Inter' or 'Poppins' and import the font in your `_app.js` or `_document.js`.
