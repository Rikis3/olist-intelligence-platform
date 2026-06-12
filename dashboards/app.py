import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go

# ====================================================================
# Project: Olist Intelligence Platform
# Phase 8: Data Visualization (Streamlit App)
# ====================================================================

st.set_page_config(page_title="Olist Intelligence Platform", layout="wide", page_icon="📈")

# --- Mock Data Generation (Simulating BigQuery Marts) ---
@st.cache_data
def load_data():
    # 1. Revenue & SLA Data
    months = ['Jan 2018', 'Feb 2018', 'Mar 2018', 'Apr 2018', 'May 2018', 'Jun 2018']
    revenue = [1.2, 1.4, 1.3, 1.5, 1.8, 1.7] # Millions
    sla_breach = [4.5, 5.0, 5.2, 6.8, 8.5, 8.0] # Percentages
    rev_sla_df = pd.DataFrame({'Month': months, 'Revenue ($M)': revenue, 'SLA Breach %': sla_breach})
    
    # 2. Regional SLA Data
    regions = ['SP (Sao Paulo)', 'RJ (Rio de Janeiro)', 'MG (Minas Gerais)', 'RS (Rio Grande do Sul)', 'BA (Bahia - Northeast)', 'PE (Pernambuco - Northeast)']
    avg_lead_time = [6, 8, 9, 12, 21, 23]
    breach_rate = [2.1, 3.5, 4.0, 6.2, 42.5, 45.1]
    regional_df = pd.DataFrame({'Region': regions, 'Lead Time (Days)': avg_lead_time, 'SLA Breach Rate (%)': breach_rate})
    
    # 3. Repeat Purchase Drop-off Data
    delivery_status = ['On-Time Delivery', 'SLA Breach (Late Delivery)']
    repeat_rate = [18.5, 4.5]
    csat_score = [4.3, 1.8]
    churn_df = pd.DataFrame({'Delivery Status': delivery_status, 'Repeat Purchase Rate (%)': repeat_rate, 'Avg CSAT': csat_score})
    
    return rev_sla_df, regional_df, churn_df

rev_sla_df, regional_df, churn_df = load_data()

# --- Sidebar Navigation ---
st.sidebar.title("Navigation")
page = st.sidebar.radio("Go to", [
    "1. Executive Overview",
    "2. Fulfillment & Logistics",
    "3. Customer Intelligence",
    "4. Strategic Recommendations"
])

st.sidebar.markdown("---")
st.sidebar.markdown("**Filters**")
year_filter = st.sidebar.selectbox("Select Year", [2018, 2017, "All Time"], index=0)

# --- Page 1: Executive Overview ---
if page == "1. Executive Overview":
    st.title("📈 Executive Overview")
    st.markdown("High-level KPIs tracking Marketplace GMV, Logistics Health, and Customer Satisfaction.")
    
    col1, col2, col3, col4 = st.columns(4)
    col1.metric("Total GMV", "$7.2M", "+12% MoM")
    col2.metric("Orders Delivered", "98.2K", "+8% MoM")
    col3.metric("SLA Breach Rate", "6.8%", "+1.2% MoM", delta_color="inverse")
    col4.metric("Avg CSAT Score", "4.1 / 5", "-0.1 MoM", delta_color="inverse")
    
    st.markdown("### Revenue vs Logistics SLA Trend")
    # Dual-axis chart
    fig = go.Figure()
    fig.add_trace(go.Bar(x=rev_sla_df['Month'], y=rev_sla_df['Revenue ($M)'], name='Revenue ($M)', marker_color='#1f77b4'))
    fig.add_trace(go.Scatter(x=rev_sla_df['Month'], y=rev_sla_df['SLA Breach %'], name='SLA Breach %', yaxis='y2', marker_color='#ff7f0e', mode='lines+markers'))
    fig.update_layout(
        yaxis=dict(title='Revenue ($M)'),
        yaxis2=dict(title='SLA Breach %', overlaying='y', side='right'),
        barmode='group',
        height=400
    )
    st.plotly_chart(fig, use_container_width=True)

# --- Page 2: Fulfillment & Logistics ---
elif page == "2. Fulfillment & Logistics":
    st.title("🚚 Fulfillment & Logistics Intelligence")
    st.markdown("Analyzing delivery bottlenecks across Brazilian regions.")
    
    col1, col2 = st.columns(2)
    with col1:
        st.markdown("### SLA Breach Rate by Region")
        fig1 = px.bar(regional_df, x='Region', y='SLA Breach Rate (%)', color='SLA Breach Rate (%)', color_continuous_scale='Reds')
        st.plotly_chart(fig1, use_container_width=True)
    with col2:
        st.markdown("### Avg Lead Time by Region")
        fig2 = px.bar(regional_df, x='Lead Time (Days)', y='Region', orientation='h', color='Lead Time (Days)', color_continuous_scale='Blues')
        st.plotly_chart(fig2, use_container_width=True)

# --- Page 3: Customer Intelligence ---
elif page == "3. Customer Intelligence":
    st.title("👥 Customer Intelligence (Logistics Impact)")
    st.markdown("How delivery performance impacts Customer Lifetime Value (CLV).")
    
    col1, col2 = st.columns(2)
    with col1:
        st.markdown("### CSAT Score by Delivery Status")
        fig1 = px.bar(churn_df, x='Delivery Status', y='Avg CSAT', color='Delivery Status', color_discrete_sequence=['#2ca02c', '#d62728'])
        fig1.update_yaxes(range=[0, 5])
        st.plotly_chart(fig1, use_container_width=True)
    with col2:
        st.markdown("### Repeat Purchase Rate Drop-off")
        fig2 = px.bar(churn_df, x='Delivery Status', y='Repeat Purchase Rate (%)', color='Delivery Status', color_discrete_sequence=['#1f77b4', '#ff7f0e'])
        st.plotly_chart(fig2, use_container_width=True)

# --- Page 4: Strategic Recommendations ---
elif page == "4. Strategic Recommendations":
    st.title("🎯 Strategic Recommendations & Root Cause")
    
    st.error("🚨 **Finding:** Customers experiencing a delivery delay of >3 days are 75% less likely to make a repeat purchase.")
    st.warning("📉 **Evidence:** SLA breach rate in the Northeast region is 45%, driving the regional CSAT down to 2.8.")
    
    st.markdown("### Proposed Actions:")
    st.markdown("1. **Logistics Expansion:** Open a secondary cross-docking hub in the Northeast (Bahia) to reduce freight lead times by an estimated 6 days.")
    st.markdown("2. **Seller Penalty System:** 60% of SLA breaches originate from sellers taking >4 days to hand off to carriers. Implement a fee penalty for sellers failing 48-hour dispatch SLAs.")
    st.markdown("3. **Revenue Recovery:** Launch a win-back email campaign offering a 15% discount code to users who experienced an SLA breach in the last 6 months to salvage LTV.")
