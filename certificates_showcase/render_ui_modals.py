import os
import subprocess

TIERS = [
    {
        "tier": 1,
        "title": "Foundational Athlete",
        "xp": 100,
        "badge": "🥉",
        "theme": "bronze",
        "primary": "#CD7F32",
        "secondary": "#8C531B",
        "border": "#D49A6A",
        "level": 1,
        "header": "KRICO FOUNDATIONAL ACCREDITATION",
        "heading": "CERTIFICATE OF ATHLETIC INITIATION",
        "accolade": "Foundation Accredited",
        "motto": "Gradus Primus Virtutis",
        "seal": "OFFICIAL INITIATE SEAL",
        "desc": "Mastered athletic discipline, session attendance, and foundational conditioning.",
        "signatories": ["Accredited Lead Coach"]
    },
    {
        "tier": 2,
        "title": "Dedicated Trainee",
        "xp": 300,
        "badge": "🌿",
        "theme": "bronze",
        "primary": "#D97706",
        "secondary": "#92400E",
        "border": "#F59E0B",
        "level": 1,
        "header": "KRICO FOUNDATIONAL ACCREDITATION",
        "heading": "CERTIFICATE OF TRAINING DISCIPLINE",
        "accolade": "Consistency Verified",
        "motto": "Assiduitas et Constantia",
        "seal": "CONSISTENCY VERIFIED SEAL",
        "desc": "Maintained training streak consistency and verified baseline drill metrics.",
        "signatories": ["Accredited Lead Coach"]
    },
    {
        "tier": 3,
        "title": "Rising Competitor",
        "xp": 600,
        "badge": "🥈",
        "theme": "silver",
        "primary": "#CBD5E1",
        "secondary": "#64748B",
        "border": "#94A3B8",
        "level": 2,
        "header": "KRICO COMPETITIVE VANGUARD",
        "heading": "CERTIFICATE OF TACTICAL COMPETENCE",
        "accolade": "Tactical Competence",
        "motto": "In Proelio Crescit",
        "seal": "TACTICAL ACCREDITATION SEAL",
        "desc": "Demonstrated tactical awareness and sharp technical execution under coach observation.",
        "signatories": ["Accredited Lead Coach", "Technical Supervisor"]
    },
    {
        "tier": 4,
        "title": "Disciplined Athlete",
        "xp": 1000,
        "badge": "🛡️",
        "theme": "silver",
        "primary": "#94A3B8",
        "secondary": "#475569",
        "border": "#E2E8F0",
        "level": 2,
        "header": "KRICO COMPETITIVE VANGUARD",
        "heading": "CERTIFICATE OF ADVANCED DISCIPLINE",
        "accolade": "Milestone Vanguard",
        "motto": "Disciplina Vincit Omnia",
        "seal": "1,000 XP VANGUARD SEAL",
        "desc": "Surpassed 1,000 career XP milestone through dedicated training camps and personal records.",
        "signatories": ["Accredited Lead Coach", "Technical Supervisor"]
    },
    {
        "tier": 5,
        "title": "Consistent Striker",
        "xp": 1500,
        "badge": "⚔️",
        "theme": "silver",
        "primary": "#38BDF8",
        "secondary": "#0369A1",
        "border": "#7DD3FC",
        "level": 2,
        "header": "KRICO COMPETITIVE VANGUARD",
        "heading": "CERTIFICATE OF ENDURANCE & STRIKING",
        "accolade": "Performance Ironclad",
        "motto": "Impetus et Fides",
        "seal": "IRONCLAD COMPETITIVE SEAL",
        "desc": "Exceptional consistency in multi-drill performance and endurance training.",
        "signatories": ["Accredited Lead Coach", "Technical Supervisor"]
    },
    {
        "tier": 6,
        "title": "Advanced Performer",
        "xp": 2200,
        "badge": "🥇",
        "theme": "gold",
        "primary": "#F59E0B",
        "secondary": "#B45309",
        "border": "#FDE68A",
        "level": 3,
        "header": "KRICO HIGH PERFORMANCE DIVISION",
        "heading": "CERTIFICATE OF HIGH PERFORMANCE MASTERY",
        "accolade": "High Performance",
        "motto": "Excellens in Corpore et Animo",
        "seal": "24K GOLD PERFORMANCE SEAL",
        "desc": "Mastered high-intensity rally and match-play drills with superior focus ratings.",
        "signatories": ["Accredited Lead Coach", "Academy Coaching Director"]
    },
    {
        "tier": 7,
        "title": "Tournament Candidate",
        "xp": 3000,
        "badge": "🦅",
        "theme": "gold",
        "primary": "#EAB308",
        "secondary": "#A16207",
        "border": "#FEF08A",
        "level": 3,
        "header": "KRICO HIGH PERFORMANCE DIVISION",
        "heading": "CERTIFICATE OF TOURNAMENT ACCREDITATION",
        "accolade": "Tournament Certified",
        "motto": "Agmen Ducere",
        "seal": "OFFICIAL TOURNAMENT SEAL",
        "desc": "Certified tournament-ready by academy coaching staff for competitive circuit entries.",
        "signatories": ["Accredited Lead Coach", "Academy Coaching Director"]
    },
    {
        "tier": 8,
        "title": "Elite Competitor",
        "xp": 4000,
        "badge": "🏅",
        "theme": "gold",
        "primary": "#FBBF24",
        "secondary": "#D97706",
        "border": "#FFFBEB",
        "level": 3,
        "header": "KRICO HIGH PERFORMANCE DIVISION",
        "heading": "DIPLOMA OF ELITE ATHLETIC EXCELLENCE",
        "accolade": "Elite Accreditation",
        "motto": "Virtus sine Fine",
        "seal": "STARBURST ROSETTE GOLD SEAL",
        "desc": "Superlative stamina, strategic acumen, and repeatable personal best achievements.",
        "signatories": ["Accredited Lead Coach", "Academy Coaching Director"]
    },
    {
        "tier": 9,
        "title": "Mastery Vanguard",
        "xp": 5500,
        "badge": "💠",
        "theme": "platinum",
        "primary": "#2DD4BF",
        "secondary": "#0F766E",
        "border": "#99F6E4",
        "level": 4,
        "header": "KRICO NATIONAL GRANDMASTER ACADEMY",
        "heading": "DIPLOMA OF MASTERY VANGUARD",
        "accolade": "Mastery Vanguard",
        "motto": "Apex Magisterii",
        "seal": "PLATINUM LAUREL ROSETTE",
        "desc": "Exemplary leadership, work ethic, and superior coach rating scorecards.",
        "signatories": ["Master Lead Coach", "Academy Technical Director", "State Athletic Board"]
    },
    {
        "tier": 10,
        "title": "Academy Champion",
        "xp": 7500,
        "badge": "👑",
        "theme": "platinum",
        "primary": "#06B6D4",
        "secondary": "#0E7490",
        "border": "#A5F3FC",
        "level": 4,
        "header": "KRICO NATIONAL GRANDMASTER ACADEMY",
        "heading": "CHAMPION OF THE ACADEMY CONFERRAL",
        "accolade": "Academy Champion",
        "motto": "Corona Victoriae",
        "seal": "CROWN EMBOSSED GRANDMASTER SEAL",
        "desc": "Ranked in the top echelon of academy athletes across endurance and technical benchmarks.",
        "signatories": ["Master Lead Coach", "Academy Technical Director", "State Athletic Board"]
    },
    {
        "tier": 11,
        "title": "Grandmaster Athlete",
        "xp": 10000,
        "badge": "💎",
        "theme": "diamond",
        "primary": "#818CF8",
        "secondary": "#4338CA",
        "border": "#C7D2FE",
        "level": 4,
        "header": "KRICO NATIONAL GRANDMASTER ACADEMY",
        "heading": "ORDER OF THE GRANDMASTER ATHLETE",
        "accolade": "Grandmaster Rank",
        "motto": "Decem Millia Virtutis",
        "seal": "DECA-MILLENNIUM DIAMOND SEAL",
        "desc": "Deca-Millennium career accomplishment. Demonstrated supreme athletic command.",
        "signatories": ["Master Lead Coach", "Academy Technical Director", "State Athletic Board"]
    },
    {
        "tier": 12,
        "title": "State-Level Contender",
        "xp": 13000,
        "badge": "🔷",
        "theme": "diamond",
        "primary": "#A855F7",
        "secondary": "#6B21A8",
        "border": "#E9D5FF",
        "level": 4,
        "header": "KRICO NATIONAL GRANDMASTER ACADEMY",
        "heading": "STATE-TIER PREMIER ACCREDITATION",
        "accolade": "State Accreditation",
        "motto": "Robur Civitatis",
        "seal": "STATE ATHLETIC DIRECTIVE SEAL",
        "desc": "Certified state-caliber competitor backed by extensive coach evaluations and verified PBs.",
        "signatories": ["Master Lead Coach", "Academy Technical Director", "State Athletic Board"]
    },
    {
        "tier": 13,
        "title": "National Prospect",
        "xp": 16500,
        "badge": "☀️",
        "theme": "diamond",
        "primary": "#EC4899",
        "secondary": "#9D174D",
        "border": "#FBCFE8",
        "level": 5,
        "header": "KRICO SUPREME COUNCIL & HALL OF FAME",
        "heading": "NATIONAL ELITE PROSPECT DIPLOMA",
        "accolade": "National Prospect",
        "motto": "Fulgur Patriam Decorat",
        "seal": "NATIONAL COUNCIL IMPERIAL SEAL",
        "desc": "Demonstrated exceptional sports acumen worthy of national-level development camps.",
        "signatories": ["Master Coach Emeritus", "Technical Director", "Council President"]
    },
    {
        "tier": 14,
        "title": "Legendary Athlete",
        "xp": 20500,
        "badge": "🌌",
        "theme": "celestial",
        "primary": "#F43F5E",
        "secondary": "#881337",
        "border": "#FECDD3",
        "level": 5,
        "header": "KRICO SUPREME COUNCIL & HALL OF FAME",
        "heading": "SOVEREIGN ORDER OF THE LEGENDARY ATHLETE",
        "accolade": "Legendary Distinction",
        "motto": "Monumentum Aere Perennius",
        "seal": "CELESTIAL IMPERIAL CREST",
        "desc": "Pinnacle of athleticism. Unmatched work ethic, peer mentorship, and tournament mastery.",
        "signatories": ["Master Coach Emeritus", "Technical Director", "Council President"]
    },
    {
        "tier": 15,
        "title": "Hall of Fame Sovereign",
        "xp": 25000,
        "badge": "🪐",
        "theme": "celestial",
        "primary": "#CCFF00",
        "secondary": "#4D7C0F",
        "border": "#ECFCCB",
        "level": 5,
        "header": "KRICO SUPREME COUNCIL & HALL OF FAME",
        "heading": "SOVEREIGN HALL OF FAME INDUCTION",
        "accolade": "Hall of Fame Immortal",
        "motto": "Ad Astra Per Aspera - In Aeternum",
        "seal": "PERPETUAL HALL OF FAME GOLD SEAL",
        "desc": "Immortalized in the KRICO Athletics Hall of Fame. Master of the Craft.",
        "signatories": ["Master Coach Emeritus", "Academy Dean", "Council President"]
    }
]

def generate_modal_html(tier_data):
    tier = tier_data["tier"]
    padded_tier = f"{tier:02d}"
    hash_suffix = f"{(tier * 1337):04X}"
    level = tier_data["level"]
    gold = "#F59E0B"
    border_color = tier_data["border"]
    primary = tier_data["primary"]
    secondary = tier_data["secondary"]
    
    corner_stars = ""
    if level >= 3:
        corner_stars = f"""
        <div style="position:absolute;top:14px;left:14px;color:{gold};font-size:14px;">✦</div>
        <div style="position:absolute;top:14px;right:48px;color:{gold};font-size:14px;">✦</div>
        <div style="position:absolute;top:auto;bottom:14px;left:14px;color:{gold};font-size:14px;">✦</div>
        <div style="position:absolute;top:auto;bottom:14px;right:14px;color:{gold};font-size:14px;">✦</div>
        """
        
    motto_html = ""
    if level >= 2:
        motto_color = gold if level >= 3 else primary
        motto_html = f"""
        <div style="margin-top:6px;display:inline-block;padding:2px 10px;background:{motto_color}18;border:1px solid {motto_color}55;border-radius:6px;font-size:9.5px;font-style:italic;font-weight:700;color:{motto_color};letter-spacing:1px;">
            ~ {tier_data['motto'].upper()} ~
        </div>
        """

    hof_banner = ""
    if level == 5:
        hof_banner = f"""
        <div style="margin-top:12px;padding:6px 12px;background:linear-gradient(90deg, #881337, #4D7C0F);border:1px solid {gold};border-radius:8px;font-size:9px;font-weight:900;color:#fff;letter-spacing:1.2px;text-align:center;">
            PERPETUAL HALL OF FAME RECORD • IMMORTALIZED
        </div>
        """

    signatory_text = " • ".join(tier_data["signatories"])

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>
    * {{ box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }}
    body {{
        background: #06090F;
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
        padding: 24px;
    }}
    .modal-container {{
        width: 480px;
        background: #0D131F;
        border-radius: 24px;
        border: {3 if level>=4 else (2.5 if level>=3 else 2)}px solid {border_color};
        box-shadow: 0 8px 32px {primary}4D, 0 16px 40px rgba(0,0,0,0.8);
        position: relative;
        overflow: hidden;
        padding: 26px 24px 22px 24px;
        color: #fff;
    }}
    .radial-glow {{
        position: absolute;
        top: -60px;
        left: 50%;
        transform: translateX(-50%);
        width: {320 if level>=4 else 260}px;
        height: {320 if level>=4 else 260}px;
        border-radius: 50%;
        background: radial-gradient(circle, {primary}3D 0%, transparent 70%);
        pointer-events: none;
    }}
    .inner-border {{
        position: absolute;
        top: {12 if level>=4 else 10}px;
        left: {12 if level>=4 else 10}px;
        right: {12 if level>=4 else 10}px;
        bottom: {12 if level>=4 else 10}px;
        border-radius: 16px;
        border: {1.5 if level>=4 else 1}px solid {gold + '55' if level>=3 else border_color + '44'};
        pointer-events: none;
    }}
    .crest-box {{
        width: {84 if level>=4 else 76}px;
        height: {84 if level>=4 else 76}px;
        margin: 10px auto 10px auto;
        border-radius: 50%;
        background: linear-gradient(135deg, {primary}, {secondary});
        border: {3.5 if level>=4 else 3}px solid {gold if level>=3 else border_color};
        box-shadow: 0 4px 20px {primary}66;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: {40 if level>=4 else 36}px;
    }}
    .close-btn {{
        position: absolute;
        top: 18px;
        right: 18px;
        width: 28px;
        height: 28px;
        border-radius: 50%;
        background: rgba(0,0,0,0.4);
        display: flex;
        align-items: center;
        justify-content: center;
        color: #94A3B8;
        font-size: 14px;
    }}
    .header-banner {{
        text-align: center;
        font-size: 9.5px;
        font-weight: 800;
        letter-spacing: 1.5px;
        color: {gold if level>=3 else primary};
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
    }}
    .cert-heading {{
        text-align: center;
        font-size: 11px;
        font-weight: 700;
        letter-spacing: 2px;
        color: rgba(255,255,255,0.7);
        margin-top: 4px;
    }}
    .cert-title {{
        text-align: center;
        font-size: {23 if level>=4 else 21}px;
        font-weight: 900;
        color: {primary};
        letter-spacing: 0.5px;
        margin-top: 2px;
    }}
    .conferred-line {{
        text-align: center;
        font-size: 11.5px;
        font-style: italic;
        color: #94A3B8;
        margin-top: 10px;
    }}
    .athlete-name {{
        text-align: center;
        font-size: 24px;
        font-weight: 800;
        color: #FFFFFF;
        letter-spacing: 0.8px;
        margin-top: 4px;
    }}
    .sport-pill {{
        display: inline-block;
        padding: 4px 12px;
        background: {primary}1F;
        border: 1px solid {primary}4D;
        border-radius: 12px;
        font-size: 10.5px;
        font-weight: 700;
        color: {primary};
        margin-top: 6px;
    }}
    .desc-text {{
        text-align: center;
        font-size: 11.5px;
        color: #94A3B8;
        line-height: 1.45;
        margin: 12px 10px 0 10px;
    }}
    .stats-box {{
        background: rgba(0,0,0,0.4);
        border: 1px solid #334155;
        border-radius: 14px;
        display: flex;
        justify-content: space-around;
        padding: 10px 12px;
        margin-top: 14px;
        text-align: center;
    }}
    .stat-label {{ font-size: 8.5px; font-weight: 700; color: #64748B; letter-spacing: 0.8px; }}
    .stat-val {{ font-size: 12px; font-weight: 800; color: #fff; margin-top: 2px; }}
    .endorsement-row {{
        display: flex;
        justify-content: space-between;
        align-items: flex-end;
        margin-top: 14px;
    }}
    .seal-box {{
        padding: 5px 10px;
        background: linear-gradient(135deg, {primary}26, {secondary}4D);
        border: {1.5 if level>=4 else 1}px solid {gold if level>=3 else border_color};
        border-radius: 8px;
        text-align: center;
    }}
    .hash-bar {{
        background: #06090F;
        border: 1px solid #1E293B;
        border-radius: 10px;
        padding: 7px 12px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-top: 12px;
        font-family: monospace;
        font-size: 10px;
        color: #94A3B8;
    }}
    .buttons-row {{
        display: flex;
        gap: 8px;
        margin-top: 14px;
        align-items: center;
    }}
    .btn-pdf {{
        flex: 1;
        padding: 10px;
        background: {gold if level>=3 else primary};
        border: none;
        color: #000;
        border-radius: 10px;
        font-weight: 800;
        font-size: 11px;
        text-align: center;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 4px;
    }}
    .btn-share {{
        flex: 1;
        padding: 10px;
        background: #1E293B;
        border: 1px solid #334155;
        color: #fff;
        border-radius: 10px;
        font-weight: 700;
        font-size: 11px;
        text-align: center;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 4px;
    }}
    .btn-share-pdf {{
        width: 36px;
        height: 36px;
        background: #1E293B;
        border: 1px solid #334155;
        color: #fff;
        border-radius: 10px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 13px;
    }}
</style>
</head>
<body>
<div class="modal-container">
    <div class="radial-glow"></div>
    <div class="inner-border"></div>
    {corner_stars}
    <div class="close-btn">✕</div>

    <div class="header-banner">
        <span>★</span>
        <span>{tier_data['header']}</span>
        <span>★</span>
    </div>

    <div class="crest-box">{tier_data['badge']}</div>

    <div class="cert-heading">{tier_data['heading']}</div>
    <div class="cert-title">{tier_data['title']}</div>
    
    <div style="text-align:center;">{motto_html}</div>

    <div class="conferred-line">
        {"By supreme decree of the board, conferred upon" if level>=4 else "This credential is formally conferred upon"}
    </div>

    <div class="athlete-name">ALEX RIVERA</div>

    <div style="text-align:center;">
        <div class="sport-pill">BADMINTON • {tier_data['accolade'].upper()}</div>
    </div>

    <div class="desc-text">{tier_data['desc']}</div>

    <div class="stats-box">
        <div>
            <div class="stat-label">MILESTONE</div>
            <div class="stat-val" style="color:{primary};">{tier_data['xp']} XP</div>
        </div>
        <div style="width:1px;background:#334155;"></div>
        <div>
            <div class="stat-label">TIER RANK</div>
            <div class="stat-val">Prestige {tier} / 15</div>
        </div>
        <div style="width:1px;background:#334155;"></div>
        <div>
            <div class="stat-label">DATE ISSUED</div>
            <div class="stat-val">Oct 10, 2026</div>
        </div>
    </div>

    <div class="endorsement-row">
        <div>
            <div style="font-size:8.5px;font-weight:800;color:#64748B;letter-spacing:1px;">
                {"EXECUTIVE BOARD ACCREDITATION" if level>=4 else "ENDORSED BY"}
            </div>
            <div style="font-size:12px;font-weight:700;color:#fff;margin-top:2px;">Coach David Vance</div>
            <div style="font-size:9px;color:#94A3B8;margin-top:1px;">{signatory_text}</div>
        </div>
        <div class="seal-box">
            <div style="font-size:14px;color:{gold if level>=3 else primary};">★</div>
            <div style="font-size:7.5px;font-weight:900;color:{gold if level>=3 else primary};letter-spacing:0.5px;">
                {tier_data['seal']}
            </div>
        </div>
    </div>

    {hof_banner}

    <div class="hash-bar">
        <span>🔒 HASH: KRC-2026-T{padded_tier}-{hash_suffix}</span>
        <span style="color:{primary};cursor:pointer;">📋</span>
    </div>

    <div class="buttons-row">
        <div class="btn-pdf">📄 Download PDF</div>
        <div class="btn-share">📷 Share Image</div>
        <div class="btn-share-pdf">📤</div>
    </div>
</div>
</body>
</html>"""
    return html

def main():
    out_dir = "certificates_showcase/ui_snapshots"
    temp_dir = "certificates_showcase/temp_html"
    os.makedirs(out_dir, exist_ok=True)
    os.makedirs(temp_dir, exist_ok=True)

    edge_path = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    print(f"Generating UI modal snapshots for all 15 certificate tiers...")

    for tier_data in TIERS:
        tier = tier_data["tier"]
        padded_tier = f"{tier:02d}"
        safe_name = tier_data["title"].lower().replace(" ", "_").replace("-", "_")
        html_content = generate_modal_html(tier_data)

        temp_html_path = os.path.abspath(os.path.join(temp_dir, f"tier_{padded_tier}.html"))
        with open(temp_html_path, "w", encoding="utf-8") as f:
            f.write(html_content)

        out_img_path = os.path.abspath(os.path.join(out_dir, f"tier_{padded_tier}_{safe_name}.png"))
        
        # Invoke headless Edge to render pixel-perfect screenshot
        cmd = [
            edge_path,
            "--headless",
            "--disable-gpu",
            "--hide-scrollbars",
            "--window-size=620,960",
            f"--screenshot={out_img_path}",
            f"file:///{temp_html_path}"
        ]
        subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        print(f"Captured UI Snapshot: tier_{padded_tier}_{safe_name}.png")

    print("All 15 UI Modal snapshots generated successfully!")

if __name__ == "__main__":
    main()
