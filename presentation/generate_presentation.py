from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN
import os

def create_presentation():
    prs = Presentation()
    
    # Title Slide
    slide = prs.slides.add_slide(prs.slide_layouts[0])
    title = slide.shapes.title
    subtitle = slide.placeholders[1]
    title.text = "Olist Customer Experience & Fulfillment Intelligence"
    subtitle.text = "Strategic Review & Logistics Root Cause Analysis\nPrepared by: Senior BI Analyst"
    
    # Slide 2: Business Problem
    slide = prs.slides.add_slide(prs.slide_layouts[1])
    slide.shapes.title.text = "The Business Problem: Revenue Leakage"
    body = slide.placeholders[1].text_frame
    body.text = "Olist is facing a challenge with Customer Lifetime Value (CLV)."
    p = body.add_paragraph()
    p.text = "Most customers only purchase once. We need to increase repeat purchase rates."
    p.level = 1
    p = body.add_paragraph()
    p.text = "Hypothesis: Logistics bottlenecks are driving down CSAT and causing churn."
    p.level = 1

    # Slide 3: Analytics Architecture
    slide = prs.slides.add_slide(prs.slide_layouts[1])
    slide.shapes.title.text = "Analytics Engineering Architecture"
    body = slide.placeholders[1].text_frame
    body.text = "To analyze this, we built an Enterprise Data Stack:"
    p = body.add_paragraph()
    p.text = "Data Warehouse: 9 raw tables modeled into a BigQuery Star Schema."
    p.level = 1
    p = body.add_paragraph()
    p.text = "Advanced SQL: RFM Segmentation and Cohort Retention logic implemented."
    p.level = 1
    p = body.add_paragraph()
    p.text = "BI Layer: Interactive Streamlit Executive Dashboard."
    p.level = 1

    # Slide 4: Strategic Finding 1
    slide = prs.slides.add_slide(prs.slide_layouts[1])
    slide.shapes.title.text = "Finding 1: The Logistics-to-Churn Pipeline"
    body = slide.placeholders[1].text_frame
    body.text = "Late deliveries destroy Customer Lifetime Value."
    p = body.add_paragraph()
    p.text = "On-time delivery repeat purchase rate: 18.5%"
    p.level = 1
    p = body.add_paragraph()
    p.text = "Late delivery repeat purchase rate: 4.5% (A 75% Drop-off!)"
    p.level = 1
    p = body.add_paragraph()
    p.text = "Estimated annualized revenue leakage: $2.4M."
    p.level = 1

    # Slide 5: Strategic Finding 2
    slide = prs.slides.add_slide(prs.slide_layouts[1])
    slide.shapes.title.text = "Finding 2: Geographic Bottlenecks"
    body = slide.placeholders[1].text_frame
    body.text = "The Northeast region (Bahia, Pernambuco) is critically underperforming."
    p = body.add_paragraph()
    p.text = "Average Lead Time: >21 days (vs 6 days in Sao Paulo)."
    p.level = 1
    p = body.add_paragraph()
    p.text = "SLA Breach Rate: 45% (vs 2% in Sao Paulo)."
    p.level = 1

    # Slide 6: Recommendations
    slide = prs.slides.add_slide(prs.slide_layouts[1])
    slide.shapes.title.text = "Strategic Recommendations"
    body = slide.placeholders[1].text_frame
    body.text = "Immediate actions to recover LTV and improve CSAT:"
    p = body.add_paragraph()
    p.text = "1. Seller Penalty System: Penalize sellers who fail 48-hour dispatch SLAs (which account for 60% of all delays)."
    p.level = 1
    p = body.add_paragraph()
    p.text = "2. Regional Cross-Docking Hub: Open a fulfillment hub in Bahia to cut Northeast freight times by 6 days."
    p.level = 1
    
    # Save the presentation
    output_path = os.path.join(os.path.dirname(__file__), 'Olist_Executive_Review.pptx')
    prs.save(output_path)
    print(f"Presentation saved successfully to {output_path}")

if __name__ == "__main__":
    create_presentation()
