module MyModule::CertificateIssuer {
    use aptos_framework::signer;
    use std::string::{Self, String};
    use std::vector;
    use aptos_framework::timestamp;

    /// Struct representing a certificate
    struct Certificate has store, key {
        recipient: address,        // Address of the certificate recipient
        title: String,             // Title/name of the certificate
        issuer: String,            // Name of the issuing authority
        issue_date: u64,           // Timestamp when certificate was issued
        certificate_id: u64,       // Unique identifier for the certificate
    }

    /// Struct to store issued certificates for an issuer
    struct CertificateRegistry has key {
        certificates: vector<Certificate>,  // List of all issued certificates
        next_id: u64,                      // Counter for certificate IDs
    }

    /// Function to initialize the certificate registry for an issuer
    public fun initialize_issuer(issuer: &signer) {
        let registry = CertificateRegistry {
            certificates: vector::empty<Certificate>(),
            next_id: 1,
        };
        move_to(issuer, registry);
    }

    /// Function to issue a new certificate to a recipient
    public fun issue_certificate(
        issuer: &signer,
        recipient: address,
        title: String,
        issuer_name: String
    ) acquires CertificateRegistry {
        let issuer_addr = signer::address_of(issuer);
        
        // Check if issuer registry exists, if not initialize it
        if (!exists<CertificateRegistry>(issuer_addr)) {
            initialize_issuer(issuer);
        };

        let registry = borrow_global_mut<CertificateRegistry>(issuer_addr);
        
        // Create new certificate
        let certificate = Certificate {
            recipient,
            title,
            issuer: issuer_name,
            issue_date: timestamp::now_microseconds(),
            certificate_id: registry.next_id,
        };

        // Add certificate to registry
        vector::push_back(&mut registry.certificates, certificate);
        
        // Increment certificate ID counter
        registry.next_id = registry.next_id + 1;
    }
}