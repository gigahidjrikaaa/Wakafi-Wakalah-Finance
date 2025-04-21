'use client';
import React, { useState, useEffect } from 'react';
// Import icons from lucide-react
import { Home, User, Briefcase, Settings, HelpCircle, LogOut, Copy, Info, Download, Upload, X, TrendingUp, Percent, AlertTriangle, Wallet, Clock, Menu } from 'lucide-react';
import { ConnectButton } from '@rainbow-me/rainbowkit';
// --- Reusable Components ---

// Sidebar Link Component (Unchanged)
const SidebarLink = ({ icon: Icon, text, active = false, href = '#' }) => (
  <a
    href={href}
    className={`flex items-center px-4 py-3 rounded-lg transition duration-200 ease-in-out ${
      active
        ? 'bg-green-700 text-white font-semibold shadow-md'
        : 'text-gray-600 hover:bg-green-50 hover:text-green-800'
    }`}
  >
    <Icon size={20} className="mr-3" />
    <span>{text}</span>
  </a>
);

// Stat Card Component (Unchanged)
const StatCard = ({ title, value, unit }) => (
  <div className="bg-white border border-gray-200 rounded-xl p-4 flex-1 text-center md:text-left shadow-sm">
    <p className="text-sm text-gray-500 mb-1">{title}</p>
    <p className="text-xl md:text-2xl font-semibold text-gray-800">
      {value} <span className="text-lg font-medium text-gray-600">{unit}</span>
    </p>
  </div>
);

// Base Modal Component (Unchanged)
const Modal = ({ isOpen, onClose, children }) => {
  if (!isOpen) return null;

  return (
    <div
      className="fixed inset-0 bg-black bg-opacity-50 z-[60] flex justify-center items-center p-4 transition-opacity duration-300" // Increased z-index
      onClick={onClose} // Close modal on overlay click
    >
      <div
        className="bg-white rounded-xl shadow-xl w-full max-w-md overflow-hidden"
        onClick={(e) => e.stopPropagation()} // Prevent closing when clicking inside modal content
      >
        {children}
      </div>
    </div>
  );
};

// --- Transaction Modals --- (Unchanged)

// Deposit Modal Component (Unchanged)
const DepositModal = ({ isOpen, onClose, onConfirm }) => {
  const [amount, setAmount] = useState('');

  const handleConfirm = () => {
    console.log('Deposit confirmed with amount:', amount);
    onConfirm(amount);
    onClose();
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose}>
      <div className="p-6">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-semibold text-gray-800">Deposit to Wakafi</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            <X size={24} />
          </button>
        </div>
        <div className="mb-6">
          <label htmlFor="deposit-amount" className="block text-sm font-medium text-gray-700 mb-1">
            Amount
          </label>
          <div className="flex items-center border border-gray-300 rounded-lg overflow-hidden focus-within:ring-2 focus-within:ring-green-500 focus-within:border-green-500">
            <input
              type="number"
              id="deposit-amount"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="0.00"
              className="flex-grow p-3 border-none focus:ring-0 text-gray-800"
            />
            <span className="bg-gray-100 text-gray-600 px-4 py-3 border-l border-gray-300 font-medium">
              PTT
            </span>
          </div>
        </div>
        <div className="mb-6 border border-gray-100 bg-gray-50 rounded-lg p-4 space-y-3">
          <h3 className="text-md font-semibold text-gray-700 mb-2">Review Summary</h3>
          <div className="flex items-start text-sm text-gray-600">
            <TrendingUp size={18} className="mr-3 mt-0.5 text-green-600 flex-shrink-0" />
            <span>Historical yield : 5,2 % APY ( based on past 6 month )</span>
          </div>
          <div className="flex items-start text-sm text-gray-600">
            <Percent size={18} className="mr-3 mt-0.5 text-green-600 flex-shrink-0" />
            <span>Ujrah ( Agency Fee ) : 1,5 % of profit per cycle</span>
          </div>
           <div className="flex items-start text-sm text-yellow-700 bg-yellow-50 p-2 rounded-md border border-yellow-200">
            <AlertTriangle size={18} className="mr-3 mt-0.5 flex-shrink-0" />
            <span>Returns are variable and not guaranteed. You bear investment risk.</span>
          </div>
        </div>
        <div className="flex gap-4">
          <button
            onClick={onClose}
            className="flex-1 bg-white border border-gray-300 text-gray-700 px-6 py-3 rounded-lg font-semibold hover:bg-gray-100 transition duration-200 shadow-sm"
          >
            Cancel
          </button>
          <button
            onClick={handleConfirm}
            disabled={!amount || parseFloat(amount) <= 0}
            className="flex-1 bg-green-700 text-white px-6 py-3 rounded-lg font-semibold hover:bg-green-800 transition duration-200 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Confirm
          </button>
        </div>
      </div>
    </Modal>
  );
};

// Withdraw Modal Component (Unchanged)
const WithdrawModal = ({ isOpen, onClose, onConfirm }) => {
  const [amount, setAmount] = useState('');
  const withdrawableBalance = 28.50; // Example balance

  const handleConfirm = () => {
    console.log('Withdraw confirmed with amount:', amount);
    onConfirm(amount);
    onClose();
  };

  return (
    <Modal isOpen={isOpen} onClose={onClose}>
      <div className="p-6">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-xl font-semibold text-gray-800">Withdraw from Wakafi</h2>
          <button onClick={onClose} className="text-gray-400 hover:text-gray-600">
            <X size={24} />
          </button>
        </div>
        <div className="mb-6">
          <label htmlFor="withdraw-amount" className="block text-sm font-medium text-gray-700 mb-1">
            Amount
          </label>
          <div className="flex items-center border border-gray-300 rounded-lg overflow-hidden focus-within:ring-2 focus-within:ring-green-500 focus-within:border-green-500">
            <input
              type="number"
              id="withdraw-amount"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              placeholder="0.00"
              className="flex-grow p-3 border-none focus:ring-0 text-gray-800"
            />
            <span className="bg-gray-100 text-gray-600 px-4 py-3 border-l border-gray-300 font-medium">
              PTT
            </span>
          </div>
           {amount && parseFloat(amount) > withdrawableBalance && (
             <p className="text-xs text-red-600 mt-1">Amount exceeds withdrawable balance.</p>
           )}
        </div>
        <div className="mb-6 border border-gray-100 bg-gray-50 rounded-lg p-4 space-y-3">
          <h3 className="text-md font-semibold text-gray-700 mb-2">Withdraw Summary</h3>
          <div className="flex items-start text-sm text-gray-600">
            <Wallet size={18} className="mr-3 mt-0.5 text-green-600 flex-shrink-0" />
            <span>Withdrawable balance : {withdrawableBalance.toFixed(2)} PTT</span>
          </div>
          <div className="flex items-start text-sm text-gray-600">
            <Clock size={18} className="mr-3 mt-0.5 text-green-600 flex-shrink-0" />
            <span>Processing time : Up to 1 hour</span>
          </div>
           <div className="flex items-start text-sm text-yellow-700 bg-yellow-50 p-2 rounded-md border border-yellow-200">
            <AlertTriangle size={18} className="mr-3 mt-0.5 flex-shrink-0" />
            <span>A fee may apply depending on the network conditions</span>
          </div>
        </div>
        <div className="flex gap-4">
          <button
            onClick={onClose}
            className="flex-1 bg-white border border-gray-300 text-gray-700 px-6 py-3 rounded-lg font-semibold hover:bg-gray-100 transition duration-200 shadow-sm"
          >
            Cancel
          </button>
          <button
            onClick={handleConfirm}
            disabled={!amount || parseFloat(amount) <= 0 || parseFloat(amount) > withdrawableBalance}
            className="flex-1 bg-green-700 text-white px-6 py-3 rounded-lg font-semibold hover:bg-green-800 transition duration-200 shadow-sm disabled:opacity-50 disabled:cursor-not-allowed"
          >
            Confirm
          </button>
        </div>
      </div>
    </Modal>
  );
};


// --- Main Layout Components ---

// Sidebar Component (UPDATED for Responsiveness)
const Sidebar = ({ isMobileOpen, onClose }) => (
  <>
    {/* Overlay for Mobile */}
    <div
      className={`fixed inset-0 bg-black bg-opacity-50 z-30 md:hidden transition-opacity duration-300 ${
        isMobileOpen ? 'opacity-100 pointer-events-auto' : 'opacity-0 pointer-events-none'
      }`}
      onClick={onClose}
    ></div>

    {/* Sidebar */}
    <aside
      className={`fixed inset-y-0 left-0 w-64 bg-white h-screen flex flex-col border-r border-gray-200 z-40 transform transition-transform duration-300 ease-in-out md:translate-x-0 ${
        isMobileOpen ? 'translate-x-0 shadow-lg' : '-translate-x-full'
      }`}
    >
      {/* Logo */}
      <div className="px-6 py-5 border-b border-gray-200 flex justify-between items-center">
        <h1 className="text-2xl font-bold text-green-700">Wakafi</h1>
        {/* Close button for mobile */}
        <button onClick={onClose} className="text-gray-500 hover:text-gray-700 md:hidden">
           <X size={24} />
        </button>
      </div>

      {/* Navigation */}
      <nav className="flex-grow p-4 space-y-2">
        <SidebarLink icon={Home} text="Dashboard" active={true} />
        <SidebarLink icon={User} text="My Portfolio" />
        <SidebarLink icon={Briefcase} text="Halal Assets" />
      </nav>

      {/* Bottom Links */}
      <div className="p-4 border-t border-gray-200 space-y-2">
        <SidebarLink icon={Settings} text="Setting" />
        <SidebarLink icon={HelpCircle} text="Help" />
        <SidebarLink icon={LogOut} text="Log Out" />
      </div>
    </aside>
  </>
);

// Header Bar Component (Inside Main Content - Unchanged)
const HeaderBar = () => (
  <div className="flex justify-end items-center mb-6">
    {/* <button className="flex items-center bg-white border border-gray-300 rounded-lg px-3 py-2 text-sm text-gray-700 hover:bg-gray-50 transition duration-150">
      <span>0xaiueo1234...</span>
      <Copy size={14} className="ml-2 text-gray-500" />
    </button> */}
    <ConnectButton/>
  </div>
);

// Mobile Header Component (NEW)
const MobileHeader = ({ onMenuClick }) => (
   <header className="md:hidden fixed top-0 left-0 right-0 z-20 bg-white shadow-sm px-4 py-3 flex items-center justify-between h-16">
      <h1 className="text-xl font-bold text-green-700">Wakafi</h1>
      <button onClick={onMenuClick} className="text-gray-600 hover:text-green-700 p-2">
         <Menu size={24} />
      </button>
   </header>
);


// Main Dashboard Content Component (UPDATED for Responsiveness)
const DashboardContent = () => {
  // State for controlling modal visibility (Unchanged)
  const [isDepositModalOpen, setIsDepositModalOpen] = useState(false);
  const [isWithdrawModalOpen, setIsWithdrawModalOpen] = useState(false);

  // Placeholder data for the table (Unchanged)
  const portfolioData = [
    { action: 'Deposit', amount: '12.00', token: 'ETH', date: '04/21/2025' },
    { action: 'Deposit', amount: '5000.00', token: 'ADA', date: '04/21/2025' },
  ];

  // Handlers for opening modals (Unchanged)
  const openDepositModal = () => setIsDepositModalOpen(true);
  const openWithdrawModal = () => setIsWithdrawModalOpen(true);

  // Handlers for closing modals (Unchanged)
  const closeDepositModal = () => setIsDepositModalOpen(false);
  const closeWithdrawModal = () => setIsWithdrawModalOpen(false);

  // Handlers for confirming actions (Unchanged)
  const handleDepositConfirm = (amount) => {
    console.log('Deposit confirmed in parent component with amount:', amount);
  };
  const handleWithdrawConfirm = (amount) => {
    console.log('Withdraw confirmed in parent component with amount:', amount);
  };


  return (
    // Added pt-16 for mobile header offset, md:pt-0 removes it on larger screens
    <div className="flex-grow p-6 md:p-8 bg-gray-50 min-h-screen pt-20 md:pt-6">
      <HeaderBar />

      {/* Stats Cards (Responsive adjustments) */}
      <div className="grid grid-cols-1 md:flex md:flex-row gap-4 md:gap-6 mb-6">
        <StatCard title="Total Deposited" value="100.00" unit="PTT" />
        <StatCard title="Total Return" value="3.50" unit="PTT" />
        <StatCard title="Total Ujrah Fee" value="0.15" unit="PTT" />
      </div>

      {/* Action Buttons (Responsive adjustments) */}
      <div className="flex flex-col sm:flex-row gap-4 mb-8">
        <button
          onClick={openDepositModal}
          className="flex-1 bg-green-700 text-white px-6 py-3 rounded-lg font-semibold hover:bg-green-800 transition duration-200 shadow-sm flex items-center justify-center gap-2"
        >
           <Download size={18} /> Deposit
        </button>
        <button
          onClick={openWithdrawModal}
          className="flex-1 bg-white border border-gray-300 text-gray-700 px-6 py-3 rounded-lg font-semibold hover:bg-gray-100 transition duration-200 shadow-sm flex items-center justify-center gap-2"
        >
           <Upload size={18} /> Withdraw
        </button>
      </div>

      {/* Portfolio Table (Unchanged, overflow-x handles responsiveness) */}
      <div className="bg-green-50/50 rounded-xl p-4 md:p-6 shadow-sm border border-green-100">
        <h2 className="text-lg font-semibold text-gray-700 mb-4">Portfolio Overview Table</h2>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm min-w-[600px]"> {/* Added min-w for better horizontal scroll */}
            <thead className="text-xs text-gray-500 uppercase border-b border-green-200">
              <tr>
                <th scope="col" className="px-4 py-3">Action</th>
                <th scope="col" className="px-4 py-3">Amount</th>
                <th scope="col" className="px-4 py-3">Token / Coin</th>
                <th scope="col" className="px-4 py-3">Date</th>
                <th scope="col" className="px-4 py-3">Detail</th>
              </tr>
            </thead>
            <tbody>
              {portfolioData.map((item, index) => (
                <tr key={index} className="bg-transparent hover:bg-green-100/50 border-b border-green-100 last:border-b-0">
                  <td className="px-4 py-3 font-medium text-gray-800">{item.action}</td>
                  <td className="px-4 py-3 text-gray-700">{item.amount}</td>
                  <td className="px-4 py-3 text-gray-700">{item.token}</td>
                  <td className="px-4 py-3 text-gray-700">{item.date}</td>
                  <td className="px-4 py-3">
                    <button className="text-gray-500 hover:text-green-700">
                      <Info size={16} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {/* Render Modals (Unchanged) */}
      <DepositModal
        isOpen={isDepositModalOpen}
        onClose={closeDepositModal}
        onConfirm={handleDepositConfirm}
      />
      <WithdrawModal
        isOpen={isWithdrawModalOpen}
        onClose={closeWithdrawModal}
        onConfirm={handleWithdrawConfirm}
      />

    </div>
  );
};


// --- Main App Component --- (UPDATED with Mobile Sidebar State)
export default function DashboardApp() {
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);

  const toggleMobileSidebar = () => {
    setIsMobileSidebarOpen(!isMobileSidebarOpen);
  };

  return (
    <div className="flex font-sans bg-gray-50 min-h-screen">
      {/* Pass mobile state and handler to Sidebar */}
      <Sidebar isMobileOpen={isMobileSidebarOpen} onClose={toggleMobileSidebar} />

      {/* Main content area */}
      {/* Apply margin offset only on medium screens and up */}
      <div className="flex-1 flex flex-col md:ml-64">
         {/* Mobile Header - shown only on small screens */}
         <MobileHeader onMenuClick={toggleMobileSidebar} />

         {/* The actual scrollable content */}
         <main className="flex-grow">
            <DashboardContent />
         </main>
      </div>
    </div>
  );
}