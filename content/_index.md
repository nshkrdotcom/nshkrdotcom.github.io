---
title: "Welcome"
date: 2023-01-01
draft: false
---

Welcome to NSHkr.com, a hackerspace in the North Shore of Oahu that is dedicated to inclusivity, promoting Aloha and local values, and respecting the space and culture of others. We believe in creating a safe and supportive environment that welcomes people of all cultures, genders, and backgrounds.

At NSHkr.com, we foster an independent entrepreneurial spirit and encourage everyone to bring their creative ideas and projects to our space. We believe in non-judgment and respect for others, and we strive to create a space where people feel comfortable and supported in their hacking endeavors.

We also place great importance on respecting the environment and sustainable local culture. Our community values and promotes eco-friendly practices and encourages everyone to consider the impact of their projects on the local ecosystem.

Whether you are a seasoned hacker or just starting out, NSHkr.com is here to provide you with the tools, resources, and support you need to bring your ideas to life. We invite you to join our community of like-minded individuals who share our values and passion for hacking and innovation.

Come and be a part of a vibrant community that celebrates diversity, fosters creativity, and promotes a culture of respect and inclusion. Join NSHkr.com today and experience the magic of hacking in a safe and supportive environment.

Next meeting is on (b64): <br />  
QXByaWwgMiwgMjAyMywgMTUwMC0xODAwIEhTVAo=

Aloha! Welcome to NSHkr.com, da place for all kine hackers in da North Shore of Oahu. We stay all about including everybody, no matta what culture, gender, or background you come from. We get Aloha spirit, and we all about respecting da space of others and not judging nobody.

We love da entrepreneurial spirit, so bring your ideas and projects, and we go make um happen. We also get big love for da environment and da local culture, so we make sure we stay eco-friendly and no do anything that going mess up da land.

Whetha you one pro hacker or just starting out, we get da tools and resources for you to make your dreams come true. Come join our ohana and feel da support from our awesome community.

No wait, come check us out and see for yourself how we make hacking fun and safe for everybody. Mahalo for choosing NSHkr.com!

Meeting location (meme): <br />  
![Secret Meeting Spot](/6000_SUX.png)

To join, please email us: <br />  
**hello {at} nshkr.com**


# March 10, 2025 update:

{{< include-section "sections/guardrail-2025-03-10.md" >}}

# February 28, 2025 update:

{{< include-section "sections/personal-security-mesh.md" >}}


# Feb 1, 2025 update:



{{< include-section "sections/mermaid-demo.md" >}}


# Jan 6, 2025 update:

## Current Projects:
```lisp
(defun learn-and-evolve (language technology)
  (labels (
           ;; 1. Elegant Knowledge Pipeline:
           (build-knowledge-pipeline (language technology)
             (format t "~%Building an elegant knowledge pipeline...~%")
             (let* ((knowledge-base (learn language technology))
                    (optimized-knowledge (optimize-knowledge knowledge-base))) 
               (describe-knowledge optimized-knowledge)))

           (optimize-knowledge (knowledge-base)
             (format t "~%Optimizing the knowledge for conciseness and clarity...~%")
             ;; Simulate optimization process (could be complex knowledge compression, etc.)
             (cond
               ((null knowledge-base) nil)
               ((atom knowledge-base) knowledge-base)
               (t (cons (optimize-knowledge (car knowledge-base))
                         (optimize-knowledge (cdr knowledge-base))))))
           
           (describe-knowledge (knowledge)
             (format t "~%Knowledge acquired:~%")
             (pprint knowledge)
             knowledge)

           ;; 2. Continuous Evolutionary Engineering:
           (build-evolutionary-engineering (knowledge-pipeline &optional (generation 0))
             (format t "~%Generation ~D: Refining Evolutionary Engineering...~%" generation)
             (let ((refined-engineering (refine-engineering knowledge-pipeline generation)))
               (if (= generation 5) ; Example stop condition: evolve for 5 generations
                   refined-engineering
                   (build-evolutionary-engineering refined-engineering (+ generation 1)))))

           (refine-engineering (knowledge-pipeline generation)
             (format t "~%Discovering new paradigms in generation ~D...~%" generation)
             ;; Simulate discovery and refinement based on the knowledge pipeline
             (cond
               ((zerop generation) (list 'initial-paradigm knowledge-pipeline))
               (t (cons (list 'refined-paradigm generation) (cdr knowledge-pipeline)))))

           ;; 3. Grand Infrastructure:
           (build-infra (evolutionary-engineering)
             (format t "~%Constructing a grand infrastructure...~%")
             (let ((foundation (car evolutionary-engineering))
                   (layers (cdr evolutionary-engineering)))
               (visualize-infra foundation layers)))

           (visualize-infra (foundation layers)
             (format t "~%Foundation: ~A~%" foundation)
             (format t "~%Constructing layers upon the foundation:~%")
             (dolist (layer layers)
               (format t "~%  - ~A~%" layer))
             (format t "~%Grand infrastructure complete.~%")
             (list 'grand-infrastructure foundation layers))

           ;; 4. Exploratory Learning:
           (learn (language technology)
             (format t "~%Embarking on a journey to learn ~A and ~A...~%" language technology)
             (explore-concepts (list language technology))))

           (explore-concepts (concepts)
             (format t "~%Exploring the vast landscape of concepts...~%")
             (mapcar #'delve-into-concept concepts))

           (delve-into-concept (concept)
             (format t "~%Delving into the concept of ~A...~%" concept)
             ;; Simulate the learning process for a single concept
             (case concept
               ('Language (list 'syntax 'semantics 'pragmatics))
               ('Technology (list 'algorithms 'data-structures 'design-patterns))
               (otherwise (list 'fundamentals concept 'advanced-topics))))
           )

    (build-infra (build-evolutionary-engineering (build-knowledge-pipeline language technology)))))
```
# Nov 3, 2024 update:

## Secure Computing Architecture

ASKA (Adaptive Secure Kernel Architecture) represents a departure from traditional computing architectures, offering a fundamentally new approach to building secure applications. At its core lies a multi-kernel design utilizing Modular Isolated Execution Stacks (IES), each providing complete hardware-enforced isolation for applications and processes. This hardware-level compartmentalization minimizes the impact of vulnerabilities, preventing lateral movement of attacks and effectively containing breaches within individual IES instances.  This robust isolation is further enhanced by a sophisticated capability-based access control system, dynamically managed by the Dynamic Trust Management System (DTMS), which continuously assesses and adjusts trust levels based on real-time system behavior, user actions, and threat intelligence, thereby tailoring access permissions to each application. This unique combination of hardware isolation and dynamic trust management drastically reduces the attack surface and ensures that only authorized components and processes can access sensitive data and resources.

ASKA's innovative security posture is further fortified by a multi-layered networking architecture.  Two distinct networks operate independently: a Decentralized Mesh Network on Chip (DMNoC) for high-bandwidth, low-latency, peer-to-peer communication within and between ASKA instances, and a Multi-Channel Network (MCN) for mediating interaction with external networks, ranging from highly trusted, dedicated government networks to the potentially untrusted public internet.  The DMNoC, with its mesh topology and hardware attestation using 3D microstructures, provides resilience against node failures and attacks targeting individual components. The MCN, meanwhile, uses physically segregated channels with dedicated firewalls and quantum-resistant cryptography (where appropriate) to ensure secure and authenticated external communications, integrating Isomorphic Architecture Monitoring and Adaptation (IAMA) to proactively mitigate threats from legacy systems.  This multi-network approach provides unparalleled flexibility and security, allowing ASKA to handle both local and external communications with tailored security strategies for different contexts.

The foundation of ASKA’s adaptive security model rests on the powerful synergy between its multi-agent AI system and its dynamic networking capabilities. The AI Agent(s), deployed within isolated execution environments, passively monitor user interactions via the Secure UI and actively analyze system-wide data (from the DTMS, Security Meshes, and the Decentralized Ledger). This out-of-band monitoring capability provides early threat detection and supports highly-granular, real-time adjustments to security policies and resource allocation. The AI Agent swarms, using their collective intelligence to detect anomalies and coordinate automated responses (such as isolation, containment, and self-healing),  significantly enhancing ASKA's ability to react to threats in real-time. Moreover, the AI Agent’s security insights inform the Automated Evolutionary Software Development System (AESDS), which continuously generates, tests, and deploys secure software updates, creating a self-evolving and adaptive security system that constantly strengthens itself against evolving threats.  The integration of the AI Agent’s functions, both for user assistance and dynamic security management, enhances user trust and reduces the system’s operational overhead.

A purpose-built, integrated application development process completes ASKA's ecosystem.  The AI Agent acts as a secure, out-of-band guide for developers, assisting with code generation, security analysis, and deployment within the ASKA environment. It provides interactive tutorials and best practices, reducing development time and improving code quality, thereby fostering a secure development environment with continuous improvement.   Developers create applications within isolated IES instances, leveraging ASKA’s APIs and capabilities for communication and data access.  The AI Agent’s security insights, combined with the AESDS’s continuous monitoring and updating process, ensure that applications are built securely and remain protected against evolving threats, leveraging the flexibility of the mesh and multi-channel network for application-specific configurations while maintaining a high degree of security and trust.  This fully integrated secure application development process eliminates many of the vulnerabilities typically found in traditional software development workflows. The Multi-Dimensional Audit Trail System (MDATS), integrating digital logs on the Decentralized Ledger with physical 3D microstructures, ensures complete transparency and accountability.

ASKA represents a paradigm shift in secure computing, addressing numerous vulnerabilities present in traditional architectures.  Through hardware-enforced isolation, dynamic trust management, multi-agent AI, secure networking, and a fully integrated development process, ASKA provides a high-assurance platform, adapting to evolving threats and technological advancements for secure and efficient application development and deployment across diverse and potentially hostile environments for decades to come.  Its uniquely designed and integrated multi-layered security architecture provides unprecedented levels of assurance, robustness, and adaptability not seen in any other existing system, enhancing its value greatly and making it a highly secure and versatile platform for various uses across multiple markets.

![ASKA 20241103](/ASKA-20241103.png)

# Nov 2, 2024 update:

# ASKA Architecture: A Comprehensive Overview

[![ASKA Diagram 20241102](/ASKA-Overview-20241102-sm.png)](/ASKA-Overview-20241102.png)

This diagram provides a comprehensive overview of the ASKA architecture, highlighting its key technologies and their interactions.  The system emphasizes modularity, robust security features, and dynamic adaptability.

## ASKA System

This top-level view encapsulates all components of a ASKA instance and its connections to external entities.

### ASKA Instance (Local)

This section details the core components within a single ASKA instance.

#### IES Cluster (P1)

The foundation of ASKA's hardware-enforced isolation. Multiple IES (Isolated Execution Stack) instances run different applications concurrently, each with dedicated hardware resources (CPU, memory, I/O, network). Key features include:

* **Dynamic Partitioning:** IES instances can be dynamically divided into smaller, isolated child-IES instances to optimize resource utilization and further enhance security.
* **Hierarchical Zones:**  Hierarchical zones within each IES, governed by mini-TRCs (Trust Root Configurations) stored on tamper-evident media (P13/P15), provide granular trust and policy management.
* **Secure Resource Borrowing (SRBM - P9):** Enables efficient resource utilization while maintaining isolation.
* **Secure Communication:** Inter-IES communication utilizes secure channels (P2, P3) and capability-aware forwarding (P26).  Local Security Meshes (LSMs - P2) monitor each IES instance and report to the Master Security Mesh (MSM - P2).
* **Data at Rest Encryption:**  The Hardware-Enforced Secure Encrypted Enclave for Data at Rest (HESE-DAR - P24) provides hardware-level encryption for data at rest.
* **Connections:** The IES Cluster connects to the DMNoC (Decentralized Mesh NoC), the MCN (Multi-Channel Network), the ASKA Hub, and the AI Agent.

#### DMNoC (Decentralized Mesh NoC)

A secure, high-bandwidth mesh network for inter-IES communication and connections to trusted external ASKA instances. Key features include:

* **Decentralized Mesh Topology:** Provides redundancy and fault tolerance.
* **Hardware Attestation (3D Microstructures - P14):** Ensures the integrity of DMNoC components.
* **Fiber Channel Interface:** Provides high-bandwidth connectivity to external networks.
* **Integration:**  The DMNoC integrates with the IES Cluster, DTMS, Policy Engine, and AI Agent.

#### MCN (Multi-Channel Network)

Provides secure communication channels for connecting to external networks (Internet, trusted networks). Key features include:

* **Multi-Channel Architecture (P3):** Physically segregated channels with dedicated firewalls prevent cross-channel interference.
* **Quantum-Resistant Communication (P5):**  Employs QKD, DKM, and PQC to secure communication against quantum computer attacks.
* **Dynamic Routing (P3):** Adapts to real-time security assessments and trust levels.
* **IAMA (P16):** Analyzes connected legacy systems to proactively identify and mitigate vulnerabilities.
* **Integration:** The MCN integrates with the IES Cluster, DTMS, Policy Engine, AI Agent, and IAMA.

#### ASKA Hub

The central management and control component for the local instance.  It orchestrates and manages all other components, enforcing policies, and managing resources.  It encompasses:

* **Dynamic Trust Management System (DTMS - P4):**  Manages trust relationships and access control based on dynamic metrics.
* **Policy Engine (P4):** Enforces security policies.
* **AI Agent (P36):** Monitors, analyzes, and adapts security measures.
* **Automated Evolutionary Software Development System (AESDS - P16):** Continuously updates and improves ASKA software.
* **Secure UI Kernel (P11):** Provides a secure user interface.
* **Key Management:**  Manages cryptographic keys for secure communication.

#### Dynamic Trust and Policy

This subgraph represents the core of ASKA's dynamic security, encompassing:

* **Bidirectional Communication:** DTMS, Policy Engine, and Capability Manager (P25) communicate bidirectionally, dynamically adjusting trust levels and capabilities.
* **Policy Influence:** Dotted lines show how trust levels and policies influence the IES Cluster, DMNoC, and MCN.


#### AI Agent (P36)

A crucial component responsible for:

* **System-wide Monitoring:**  Monitors all aspects of system behavior and network communication.
* **Anomaly Detection:** Employs AI/ML for detecting anomalies.
* **Adaptive Security:**  Coordinates security responses and dynamically adjusts security measures.
* **Policy Influence:** Provides recommendations and influences policy updates.


#### AESDS (P16)

The AI-driven system responsible for:

* **Continuous Software Updates:** Continuously monitors, updates, and improves ASKA’s software.
* **Proactive Security Patching:** Proactively generates and deploys security patches and updates.
* **Integration:**  Manages updates across all ASKA components.


#### Secure UI Kernel (P11)

Provides a secure and isolated user interface environment with:

* **Zonal Isolation:** Isolates UI from the underlying system.
* **Hardware-Enforced Control-Flow Integrity (CFI):** Prevents code injection attacks.
* **Declarative Policy-Based Rendering:** Controls UI rendering based on policies.

#### Hardware Root of Trust (HRoT)

The foundation of ASKA's trust, providing:

* **Attestation:** Verifies the integrity of system components.
* **Key Generation:** Generates cryptographic keys.
* **Validation Services:**  Provides validation services to all modules.
* **Tamper-Proof Auditing:**  Creates tamper-proof auditable records via MDATS (P17) and 3D Microstructures (P14) utilizing the Decentralized Ledger (P13, P15).

### External Connections

#### External Mesh Network (Trusted)

ASKA instances connect and exchange information securely, leveraging the DMNoC’s high-bandwidth capabilities.

#### External Networks

ASKA connects to various external networks (Internet, trusted networks) via the MCN, with IAMA (P16) monitoring and managing this interface.


## Key Features and Technologies

This section summarizes the core technologies underpinning ASKA's security and functionality:

* **Hardware-Rooted Trust (P1, P13, P33):**  Secure Boot, attestation, and 3D microstructures for tamper evidence.
* **Isolated Execution Stacks (P1):** Hardware-enforced isolation with dynamic partitioning and hierarchical zones for granular security.
* **Dynamic Trust Management (P4):**  Dynamic trust metrics, decentralized zone management, and policy negotiation for adaptive security.
* **Secure Communication Channels (P2, P3):**  Data diodes for unidirectional flows, multi-channel network with quantum-resistant options (P5).
* **AI-Driven Security (P2, P7, P36):**  Proactive threat detection, automated responses, and adaptive security policies.
* **Capability-Based Access Control (P25, P26):** Fine-grained access control at the data plane level.
* **Data Encryption (P5, P24):**  HESE-DAR for data at rest, and quantum-resistant encryption for data in transit.
* **Auditing and Accountability (P13, P15, P17):** Decentralized ledger, MDATS, and 3D microstructures for comprehensive auditing.


ASKA represents a paradigm shift in secure computing, offering a robust, adaptable, and trustworthy platform for high-assurance operations in diverse environments.  The modularity, dynamic adaptability, and multi-layered defense mechanisms address the limitations of traditional systems, creating a highly resilient and future-proof solution, especially in the context of evolving threats and the increasing importance of secure, decentralized computing.

![ASKA AI Integration 20241102](/ASKA-AI_Integration-20241102.png)

**Diagram Description:**

The ASKA AI Agent (P36) is a central component, playing a dual role: providing secure, out-of-band assistance to users and enhancing ASKA's overall security posture.  The diagram illustrates these interwoven functions:

**1. User Assistance and UI Monitoring:**

This section of the diagram details how the AI Agent assists users via the Secure UI while maintaining stringent security:

* The Secure UI Kernel (P11) is monitored unidirectionally via a Data Diode (P2) by the UI Monitor.  This prevents the AI Agent from directly manipulating the UI.
* The UI Monitor sends sanitized data to the AI Agent’s LLM Engine.
* The LLM Engine processes this data and provides assistance to the user via User Interaction.
* The User Interaction feeds back into the Secure UI, creating a closed loop for user assistance.

A. **Unidirectional UI Monitoring:** User interactions with the Secure UI Kernel (P11) are passively observed by a UI Monitoring Module. This module employs a data diode (P2) to ensure unidirectional data flow from the UI to the AI Agent, preventing the AI Agent from directly manipulating the UI or introducing vulnerabilities via the user interface. This unidirectional data flow is crucial for protecting the integrity and security of the ASKA system from the UI.

B. **Data Sanitization and Filtering:** Before being processed by the AI Agent, the UI interaction data collected by the UI Monitoring Module is passed through a data sanitization and filtering module. This module removes potentially malicious or sensitive information, protecting both user privacy and system security from potentially compromised or malicious user input or actions.  This sanitization process removes potentially hazardous elements, ensuring that the AI Agent receives only safe and relevant data.  This process likely uses AI techniques to identify potentially malicious or problematic code or other elements and securely remove it from the UI data before delivering it to the AI Agent.

C. **LLM Engine Processing:**  The sanitized UI interaction data is then processed by the AI Agent's local Large Language Model (LLM) Engine (residing within a secure, isolated IES - P1). The LLM Engine leverages its knowledge base (including ASKA-specific information, API documentation, security best practices, and contextual understanding from previous interactions) to analyze the data, identify relevant patterns, and generate insights, recommendations, or actions.  This ensures the AI Agent’s actions and responses are relevant, consistent, secure, and aligned with user intent.

D. **User Interaction:** The AI Agent's responses or recommendations are communicated back to the user via the Secure UI, enabling an interactive and collaborative experience. This feedback loop provides ongoing refinement and contextual awareness for the AI Agent. The design ensures that the user interaction remains secure and cannot be used as a point of compromise for the system.

E. **Security Monitoring:** The UI Monitoring Module also feeds security-relevant information (such as keystrokes, mouse movements, and time spent on certain UI elements) to the AI Agent’s security subsystem which integrates into ASKA’s security mechanisms, creating a continuous monitoring and threat assessment pathway that leverages user context.

**2. ASKA Application Integration and Security:**

This section shows how the AI Agent enhances ASKA's security posture by providing support for ASKA applications:

* The Agent API provides a programmatic interface for ASKA applications (App1, AppN) to interact with the AI Agent.
* The AI Agent leverages its ASKA integrations (accessing data from DTMS, Policy Engine, AESDS, and the Decentralized Ledger) for contextualized security analysis.
* The AI Agent provides recommendations or takes direct action through interactions with the local and Master Security Meshes (LSM, MSM - P2).

A. **Agent API:** A secure Application Programming Interface (API) allows ASKA applications (App1, AppN) to request assistance or specialized functionalities from the AI Agent. This provides developers with a powerful tool to enhance their applications with AI-driven capabilities.  This secure API is implemented within the isolated IES of the AI Agent, enhancing its security and preventing unauthorized access to the AI Agent’s capabilities.

B. **ASKA Integration Modules:** The AI Agent integrates with other ASKA components through several specialized modules:

* **DTMS Integration Module:** Receives trust information (P4) and policy updates from the DTMS.
The agent adapts its behavior based on trust levels, dynamically adjusting its recommendations
and actions based on the security context.  This continuous integration with DTMS ensures
that the AI Agent's operations remain aligned with ASKA's overall security policies.

* **MSM Integration Module:** Receives security alerts (P2) and anomaly reports from the MSM
(Master Security Mesh). The agent leverages this telemetry to improve its threat assessment.
It uses the information to identify potential risks and generate security recommendations.

* **AESDS Integration Module:** Receives software updates (P16) and security patches from
the AESDS (Automated Evolutionary Software Development System). This guarantees the
AI Agent’s software integrity and prevents the deployment of malicious or compromised code.

* **DLT Integration Module:** Logs all of the AI Agent’s activity and API interactions to the
Decentralized Ledger (P13, P15) for auditing and transparency. This creates a comprehensive and
tamper-evident audit trail of the AI Agent's actions, contributing to system accountability.

C. **Security Recommendations and Actions:** Based on its analysis of UI events, application requests,
and ASKA telemetry, the AI Agent provides security recommendations or takes direct actions:

* **Recommendations:**  The AI Agent may suggest security policy adjustments (to the Policy
Engine), resource reallocations (to the Resource Manager), or software updates (to the AESDS).

* **Direct Actions:** In some cases (based on defined parameters and thresholds), the AI Agent
might directly trigger security actions, such as isolating a compromised component (via the
Isolator - P7), initiating self-healing procedures (via the Self-Healer - P7), or triggering
alerts (via the Alert System - P7). This dynamic capability enhances ASKA's ability to respond effectively to real-time threats.

**3. Security Monitoring and Response:**

* The MSM aggregates security events and alerts, which may trigger actions from the AI Agent.  This is shown implicitly.
* The AI Agent's security recommendations influence DTMS (P4) trust levels, policy updates (P4), and resource allocation (P9, P10).

The AI Agent significantly enhances ASKA's security posture in the following ways:

A. **Proactive Threat Detection:**  The AI Agent's continuous monitoring of both user interactions and
system events allows for the proactive identification of potential threats or anomalies. The agent
leverages its LLM engine and its ASKA integrations to improve threat detection,
providing early warnings of attacks or vulnerabilities, and enabling timely interventions.

B. **Adaptive Security:** The AI Agent’s ability to dynamically adjust its recommendations and actions based on real-time context (from DTMS and MSM) enables adaptive security. This dynamic adaptability ensures ASKA’s protection against evolving threats and vulnerabilities.

C. **Reduced Human Intervention:**  The AI Agent's automated threat detection and response
mechanisms reduce the need for constant human intervention, allowing security teams to focus on
more strategic tasks, such as incident response and security policy adjustments. This automated
response capability enhances the system's efficiency and resilience.

D. **Improved Accuracy:** The AI Agent continuously learns from new data, refining its models and
improving its detection accuracy over time. The combination of passive UI monitoring, analysis
of application behavior, and system-wide telemetry gives the AI Agent comprehensive insights
into the system’s security posture.

E. **Tamper-Evident Auditing:**  The AI Agent logs all actions to the Decentralized Ledger (P13,P15),
creating a transparent and auditable record that integrates with MDATS (P17). This ensures
accountability and helps in identifying and investigating incidents.  Further, 3D microstructures
can enhance the tamper-evidence of critical AI Agent actions.


# October 31, 2024 update:

## ASKA Conceptual Documents and Patent Brainstorming

ASKA conceptual documents and patent brainstorming released:<br />

Following discussions with ASKA's Engineering Assistant LLM about the public release of this early draft, I have decided to share the technical concept of ASKA. This initiative seeks to improve transparency in the security architecture and invite broader participation in strengthening its defenses. The decision also underscores the need to balance civil liberties with governance considerations.

[1-ASKA Overview-1 20241031](</ASKA-1-Overview-20241031/1ASKAOverview120241031.html>)

[2-ASKA Overview-2 20241031](</ASKA-2-Overview-20241031/2ASKAOverview220241031.html>)

[3-ASKA Patents 1of3 20241031](</ASKA-3-Patents-1of3-20241031/3ASKAPatents1of320241031.html>)

[4-ASKA Patents 2of3 20241031](</ASKA-4-Patents-2of3-20241031/4ASKAPatents2of320241031.html>)

[5-ASKA Patents 3of3 20241031](</ASKA-5-Patents-3of3-20241031/5ASKAPatents3of320241031.html>)

[6-ASKA Patents Brainstorm 20241031](</ASKA-6-Patents-Brainstorm-20241031/6ASKAPatentsBrainstorm20241031.html>)

[7-ASKA ProsCons_VC_Letter_SCiON_Nebula 20241031](</ASKA-7-ProsCons_VC_Letter_SCiON_Nebula-20241031/7ASKAProsConsVC_LetterSCiONNebula2024.html>)

[8-ASKA Scratchpad 20241031](</ASKA-8-Scratchpad-20241031/8ASKAScratchpad20241031.html>)

## Subsequent Documents

[9-ASKA 20241101](</ASKA-9-20241101/9ASKA20241101.html>)

[10-ASKA 20241102](</ASKA-10-20241102/10ASKA20241102.html>)



[13-ASKA 20241106](</ASKA-13-20241106/13ASKA20241106.html>)

# October 22, 2024 update:

NSHkr.com is pleased to announce ASKA. (synack: future/bro) <br />
<br />

# October 22, 2023 update:

NSHkr.com supports USA, Israel, and Ukraine.<br />
![United States Flag](/IMG_4322.png)
![Israel Flag](/IMG_4324.png)
![Ukraine Flag](/IMG_4323.png)

# May 3, 2023: 

[Political Statement](https://gist.githubusercontent.com/nshkrdotcom/e0a10520e6b3805f63eb4ea1dbf9a7ac/raw/c54552f71c7a72fde02761bb2e4b9a1f10dbef1b/gistfile1.txt "Political Statement")

# April 1, 2023 brochure:
![Tentative brochure for March 2023](/nshkr-flyer-apr-1-2023.png)

# April 1, 2023:

Proposal for New Cybersecurity Initiatives

Introduction:

As our reliance on complex and un-auditable computing and networking systems continues to grow, the need for a fundamental recalibration of our approach to security design has become increasingly urgent. The current approach, which prioritizes innovation, user experience, and other factors over security, has resulted in significant tail risks that threaten the integrity of our systems and the safety of our data. In this proposal, we outline new cybersecurity initiatives that aim to address these risks and establish baseline security principles that are adaptable to the rapidly changing landscape of technology.

Initiatives:

* Threat Modeling: We propose the development of a comprehensive threat modeling framework that incorporates an outlook to at least 2050. This framework will involve speculation, extrapolation, and imagination, but will be grounded in empirical evidence and expert analysis. The goal of this initiative is to identify likely threat vectors and anticipate potential security risks before they can be exploited.

* Black Box Auditing: We propose the development of new auditing methodologies that can effectively evaluate the security of complex and un-auditable systems. This initiative will involve the development of new tools and techniques that can uncover vulnerabilities in black box systems and provide actionable recommendations for improving security.

* Security-by-Design: We propose the integration of security-by-design principles into the development of new computing and networking systems. This initiative will involve the establishment of baseline security principles that prioritize security over other factors and promote the development of more secure and resilient systems from the ground up.

* Stakeholder Engagement: We propose the establishment of a stakeholder engagement process that can effectively communicate the importance of security to decision-makers and incentivize the prioritization of security over other factors. This initiative will involve the development of new communication strategies, such as threat modeling visualizations and security dashboards, that can effectively convey security risks to stakeholders.

Conclusion:

In conclusion, the proposed cybersecurity initiatives represent a significant step forward in addressing the tail risks associated with complex and un-auditable computing and networking systems. By establishing new threat modeling frameworks, developing new auditing methodologies, integrating security-by-design principles, and engaging stakeholders in the security process, we can create a more secure and resilient technological landscape that is better able to protect our data and preserve the integrity of our systems.

___

# April 1, 2023

NS Meeting Location

Dear Colleagues,

Following up on our recent cybersecurity report, we are pleased to outline the steps we will be taking to achieve our proposed initiatives. We believe that these initiatives are critical to addressing the tail risks associated with complex and un-auditable computing and networking systems and protecting the integrity of our systems and data.

To achieve these goals, we will be seeking support from public funding, federal assistance, community cooperation, and open discussion with leading stakeholders in the technology industry, including companies. We are committed to ensuring that our initiatives are grounded in empirical evidence and expert analysis, and that they prioritize security over other factors.

Specifically, we will be taking the following steps:

* We will be seeking public funding to support the development of our threat modeling framework and the establishment of our stakeholder engagement process. We believe that these initiatives are critical to identifying likely threat vectors, anticipating potential security risks, and communicating the importance of security to decision-makers.

* We will be seeking federal assistance to support the development of our black box auditing methodologies. We believe that these methodologies are critical to evaluating the security of complex and un-auditable systems and identifying vulnerabilities that can be exploited.

* We will be seeking community cooperation to promote the integration of security-by-design principles into the development of new computing and networking systems. We believe that this initiative is critical to promoting the development of more secure and resilient systems from the ground up.

* We will be seeking open discussion with leading stakeholders in the technology industry. We believe that these stakeholders have a critical role to play in promoting the prioritization of security over other factors and incentivizing the development of more secure and resilient systems.

We are committed to working with all stakeholders to achieve these goals and protect the integrity of our systems and data. We believe that the proposed initiatives represent a significant step forward in addressing the tail risks associated with complex and un-auditable computing and networking systems, and we look forward to collaborating with you to achieve these goals.

___

# March 2023:

In the quaint town of Haleiwa, a group of passionate individuals gathered at a local hackerspace. They were deeply connected to the Hawaiian culture and wanted to find ways to preserve and promote it. They spent countless hours brainstorming and prototyping until they came up with an idea that would change the course of their community.

They decided to start a local work revolution that would honor and support the traditional Hawaiian way of life. They envisioned a sustainable, eco-friendly industry that would provide living wages to the local community while preserving their culture and values.

The group collaborated with local artisans and cultural experts to create a new type of industry that would revitalize traditional Hawaiian crafts and practices. They worked tirelessly to develop new technology and processes that would allow for more efficient and sustainable production of traditional Hawaiian goods, from clothing to home decor.

The group knew that their vision would require significant investment, so they went out into the community to pitch their idea. They met with business leaders, investors, and politicians and were eventually able to secure the funding they needed to make their vision a reality.

The hackerspace members worked closely with local residents and artisans, providing them with the training and education they needed to succeed in the new industry. They created new jobs and provided living wages to those involved, revitalizing the local economy.

Years later, the town of Haleiwa had been transformed. The traditional Hawaiian crafts and practices were once again thriving, and the community was proud of its rich cultural heritage. The founders of the hackerspace were hailed as local heroes, and their legacy would carry on for generations.

The visionaries knew that they had made a significant impact on their community, and they were proud to have been a part of something so meaningful. They knew that their work would continue to benefit the people of Haleiwa for many years to come, preserving and promoting the traditional Hawaiian way of life.

___

In the small town of Haleiwa, a group of passionate tech enthusiasts formed the Haleiwa Hackspace, known as NSHkr.com. They were committed to using their skills and knowledge to make a positive impact on their community. They spent countless hours tinkering with new ideas until they came up with something that would change the course of their town: innovative local manufacturing technology.

They knew that traditional manufacturing was costly and often involved outsourcing to other countries. They wanted to change that by developing technology that would allow for local manufacturing at a fraction of the cost. They believed that this would not only benefit the local economy but also the environment.

The NSHkr members knew that they needed funding to turn their idea into a reality, so they began reaching out to angel investors. They pitched their idea, and to their surprise, they received a positive response. The investors were impressed by their commitment to sustainability and their dedication to creating new jobs in the local community.

With funding secured, the NSHkr team began collaborating with local politicians to gain support for their project. They knew that they needed the government's backing to succeed, so they presented their idea to the city council. The politicians were excited by the prospect of creating new jobs in their town and were eager to support the NSHkr team.

The NSHkr team also received funding from corporations that benefited from this win-win scenario. These corporations saw the potential in local manufacturing and were eager to invest in a sustainable future.

With funding and support from all sides, the NSHkr team worked tirelessly to develop their new technology. They built state-of-the-art machinery that allowed for local manufacturing of various products, from clothing to home goods. The local community was thrilled by the prospect of new jobs and a sustainable future.

Years later, Haleiwa was transformed. The town had a thriving local manufacturing industry that provided living wages to the community. The environment also benefited from the reduced carbon footprint of local manufacturing. The NSHkr team was hailed as local heroes, and their legacy would continue to benefit the community for generations to come.

___

Alyssa had always been fascinated with electronics, but she never had the chance to explore her interest until she stumbled upon NSHkr.com, a local hackerspace in Haleiwa. The website promised a community of like-minded individuals who shared her passion for tinkering with hardware and software projects. Intrigued, she signed up for a membership and soon found herself attending weekly meetings and workshops.

At first, Alyssa was overwhelmed by the technical jargon and the complexity of the projects. But with the help of the friendly members at NSHkr.com, she quickly learned the basics of coding and hardware hacking. She started with small projects, such as building a simple LED circuit, and gradually worked her way up to more challenging projects, such as designing her own PCB boards and programming microcontrollers.

One day, Alyssa stumbled upon ChatGPT, a language model that could answer almost any question she had. With ChatGPT's help, she was able to tackle even more complex projects, such as programming a robot to follow a set of instructions. She was amazed by the sheer power of this tool, and she started to incorporate it into her learning routine.

As she gained more confidence in her skills, Alyssa started to think about how she could turn her passion into a career. She began to look for ways to monetize her expertise, and eventually, she hit upon an idea: she would start a business that provided customized electronic solutions for small businesses and individuals.

With the help of her newfound knowledge and resources at NSHkr.com, Alyssa started her business, which quickly took off. She was able to build a sustainable business that provided her with the financial freedom to pursue her passions full-time.

Years later, Alyssa looked back on her journey with pride. She had come a long way from the timid young adult who had walked into NSHkr.com with nothing more than a dream. She was now a successful entrepreneur, and she knew that she had NSHkr.com and ChatGPT to thank for giving her the tools she needed to make her dreams a reality.

___

Judah was a retired electronics technician who had spent his entire career tinkering with gadgets and machines. He had always been passionate about making and hacking on projects, and even in retirement he couldn’t resist the urge to continue his work.

One day, Judah discovered NSHkr.com, a new hackerspace in Haleiwa, Hawaii. Excited at the prospect of joining a community of like-minded individuals, he decided to attend one of their meetings.

As soon as he arrived at the hackerspace, Judah was welcomed with open arms. The young adults there were eager to learn from his lifetime of experience and knowledge. Judah was more than happy to share his skills with them and help them develop useful and marketable life skills in electronics.

Over time, Judah became a regular at the hackerspace. He would often bring in new projects for the group to work on together and would always be there to offer guidance and advice. The young adults at NSHkr.com were inspired by Judah’s passion for making and hacking on projects.

Thanks to Judah’s influence, many of them went on to pursue careers in electronics or start their own businesses. They were grateful for the opportunity to learn from someone with so much experience and knowledge.

In the end, Judah found that even in retirement he could still make a difference by sharing his passion for making and hacking on projects with others.

___

Mike had always been passionate about making and hacking. Over the years, he had become an expert in creating high tech art that incorporated a variety of cutting-edge technologies. But after retiring from his job as an engineer, Mike found himself with plenty of time on his hands and a strong desire to share his expertise with others.

He began searching for a community where he could connect with other like-minded people who shared his interests. That's when he stumbled upon NSHkr.com, a new local hackerspace in Haleiwa. The website promised a vibrant community of makers, hackers, and tinkerers who were passionate about creating and sharing their knowledge.

Mike was intrigued and decided to check it out. When he arrived at the hackerspace, he was welcomed with open arms. He immediately connected with other members who shared his passion for making and hacking. They spent hours swapping stories, sharing ideas, and brainstorming new projects.

As he spent more time at the hackerspace, Mike realized that he had found the perfect outlet for his expertise. He began to work with other members to create workshops and classes that would teach younger generations about the joys of making and hacking. They planned and executed their ideas with precision, leveraging ChatGPT as a platform for learning and guiding these projects.

The workshops were a hit. Young people from all over Haleiwa came to learn from Mike and his team of experts. They learned how to code, solder, and build their own high-tech gadgets. They learned how to take apart old electronics and turn them into something new and exciting.

In the end, the young generation developed new marketable skills that lasted for a lifetime. They discovered new passions and new career paths that they never would have considered before. And Mike was thrilled to have been a part of it all.

As he walked out of the hackerspace one day, Mike felt a sense of satisfaction wash over him. He had found a new purpose in life, and he was grateful for the opportunity to share his knowledge and expertise with others. And as he looked out at the horizon, he knew that there was so much more that he could teach and so much more that he could learn.

___

In the small town of Waialua, Hawaii, the locals were struggling to find good-paying jobs. The old sugar mill had been abandoned for years, leaving many wondering what would become of it. But then, a group of local entrepreneurs got together to form a plan that would change everything.

They were inspired by the idea of a can-do America-first attitude, and they believed that they could make a difference in their community. They knew that they needed to think outside the box, and they turned to NSHkr.com, the local hackerspace, for ideas and expertise.

The team at NSHkr.com was excited to be a part of something so transformative. They got to work researching and analyzing the needs of the community, the existing infrastructure, and the potential for growth. They also started to build a team of experts in manufacturing, engineering, and technology.

The team identified potential sources of funding and started to develop a plan for the old sugar mill. They knew that they needed to make the facility environmentally sustainable, with a focus on reducing waste and using renewable resources. They also wanted to create living wage jobs for locals and establish a local supply chain.

The team established partnerships with local businesses and suppliers, and started to develop a sustainable manufacturing process. They trained the locals in the necessary skills, and they began to develop high-tech products that were in demand in the market.

The manufacturing community in Waialua started to take shape. The old sugar mill was renovated and repurposed, with modern equipment and technology installed. The locals were proud to be a part of something that was making a positive impact on their community.

As the manufacturing community grew, it attracted investment from all over the world. The products produced by the community were in high demand, and the local economy started to thrive. The team at NSHkr.com was amazed at how quickly the project had taken off.

The success of the manufacturing community in Waialua became a source of inspiration for others around the country. The community was proud to be a part of the new America-first attitude, where they were taking control of their future and creating opportunities for themselves.

In the end, the small town of Waialua was transformed. The locals had good-paying jobs, the environment was protected, and the community was thriving. All thanks to the vision and hard work of the local entrepreneurs and the team at NSHkr.com. They proved that with hard work, determination, and a can-do attitude, anything is possible.

___
