import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import streamlit as st

st.set_page_config(page_title="E-Commerce Analytics", layout="wide")

EXPORT_DIR = "data/exports"

st.title("E-Commerce Analytics Platform")
st.caption("Source: Pre-compiled Parquet files | Architecture: ELT with dbt + DuckDB")

@st.cache_data
def load_parquet(name):
    return pd.read_parquet(f"{EXPORT_DIR}/{name}.parquet")

revenue = load_parquet("mart_revenue_monthly")
cohort = load_parquet("mart_cohort_retention")
clv = load_parquet("mart_clv")
category = load_parquet("mart_category_performance")
seller = load_parquet("mart_seller_performance")
delivery_reviews = load_parquet("mart_delivery_reviews")

view = st.sidebar.selectbox(
    "Select View",
    [
        "Revenue Trend",
        "Cohort Retention Heatmap",
        "Category Performance",
        "Delivery Delay vs Review Score",
        "CLV by Acquisition Cohort",
    ],
)

if view == "Revenue Trend":
    st.subheader("Monthly Revenue Trend")
    fig = px.line(
        revenue,
        x="order_month",
        y="total_revenue",
        markers=True,
    )
    fig.update_layout(yaxis_title="Total Revenue (BRL)", xaxis_title="")
    st.plotly_chart(fig, use_container_width=True)

    col1, col2, col3 = st.columns(3)
    col1.metric("Total Orders", f"{revenue['total_orders'].sum():,}")
    col2.metric("Total Revenue", f"R$ {revenue['total_revenue'].sum():,.0f}")
    col3.metric("Avg Order Value", f"R$ {revenue['total_revenue'].sum() / revenue['total_orders'].sum():,.2f}")

elif view == "Cohort Retention Heatmap":
    st.subheader("Cohort Retention Heatmap")
    pivot = cohort.pivot(
        index="cohort_month",
        columns="period",
        values="retention_pct",
    )
    pivot.columns = [f"M{c}" for c in pivot.columns]

    fig = go.Figure(
        data=go.Heatmap(
            z=pivot.values,
            x=list(pivot.columns),
            y=pivot.index.astype(str),
            colorscale="Blues",
            zmin=0,
            zmax=100,
            text=pivot.values,
            texttemplate="%{text:.1f}%",
            textfont={"size": 10},
        )
    )
    fig.update_layout(xaxis_title="Months Since Acquisition", yaxis_title="Cohort Month")
    st.plotly_chart(fig, use_container_width=True)

elif view == "Category Performance":
    st.subheader("Category Performance: Revenue vs Review Score")
    plot_data = category.dropna(subset=["avg_review_score"])
    fig = px.scatter(
        plot_data,
        x="total_revenue",
        y="avg_review_score",
        size="total_orders",
        hover_name="product_category_name_english",
        log_x=True,
    )
    fig.add_hline(y=3.5, line_dash="dash", line_color="red", annotation_text="Score 3.5")
    fig.update_layout(xaxis_title="Total Revenue (log scale)", yaxis_title="Avg Review Score")
    st.plotly_chart(fig, use_container_width=True)

    st.subheader("Category Details")
    st.dataframe(
        category[[
            "product_category_name_english", "total_revenue", "total_orders",
            "avg_review_score", "revenue_rank", "review_rank"
        ]].sort_values("total_revenue", ascending=False),
        use_container_width=True,
    )

elif view == "Delivery Delay vs Review Score":
    st.subheader("Delivery Delay vs Review Score")
    bucket_order = [
        '-10 or less', '-9 to -5', '-4 to -1', 'On time',
        '1 to 5', '6 to 10', '11 to 20', '21+'
    ]
    delivery_reviews['delay_bucket'] = pd.Categorical(
        delivery_reviews['delay_bucket'],
        categories=bucket_order,
        ordered=True
    )
    delivery_reviews_sorted = delivery_reviews.sort_values('delay_bucket')

    fig = px.bar(
        delivery_reviews_sorted,
        x="delay_bucket",
        y="avg_review_score",
        color="avg_review_score",
        color_continuous_scale="RdYlGn",
    )
    fig.add_hline(y=3.0, line_dash="dash", line_color="red", annotation_text="Score 3.0")
    fig.update_layout(xaxis_title="Delivery Delay (days relative to estimate)", yaxis_title="Average Review Score")
    st.plotly_chart(fig, use_container_width=True)

    col1, col2 = st.columns(2)
    col1.metric("Orders On Time", f"{delivery_reviews[delivery_reviews['delay_bucket'] == 'On time']['total_orders'].sum():,}")
    col2.metric("Orders 21+ Days Late", f"{delivery_reviews[delivery_reviews['delay_bucket'] == '21+']['total_orders'].sum():,}")

elif view == "CLV by Acquisition Cohort":
    st.subheader("CLV by Acquisition Cohort")
    fig = px.bar(
        clv,
        x="cohort_month",
        y="avg_annualized_clv",
    )
    fig.update_layout(xaxis_title="Cohort Month", yaxis_title="Avg Annualized CLV (BRL)")
    st.plotly_chart(fig, use_container_width=True)

    col1, col2 = st.columns(2)
    col1.metric("Avg Lifetime Revenue", f"R$ {clv['avg_total_revenue'].mean():,.2f}")
    col2.metric("Median Annualized CLV", f"R$ {clv['median_annualized_clv'].median():,.2f}")