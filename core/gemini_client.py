import os, base64, fitz
import google.generativeai as genai
from core.supabase_client import get_project_context, store_project_context

genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

def summarize_project(project_data: dict) -> str:
    prompt = f"""
    Summarize this student project for faculty evaluation:
    Title: {project_data.get('title')}
    Description: {project_data.get('description')}
    Guide: {project_data.get('guideName')}
    Co-Guide: {project_data.get('coGuideName')}
    Students: {', '.join(project_data.get('students', []))}
    Repository: {project_data.get('githubRepo')}
    """
    model = genai.GenerativeModel("gemini-2.5-flash")
    response = model.generate_content(prompt)
    return response.text.strip()

def extract_text_from_pdf_field(project_data):
    """Decode Base64 PDF → Extract plain text."""
    pdf_info = project_data.get("projectSummaryPdf")
    if not pdf_info or not pdf_info.get("data"):
        return None
    try:
        pdf_bytes = base64.b64decode(pdf_info["data"])
        pdf_doc = fitz.open(stream=pdf_bytes, filetype="pdf")
        text = ""
        for page in pdf_doc:
            text += page.get_text("text")
        pdf_doc.close()
        return text.strip()
    except Exception as e:
        print(f"PDF Extraction Error: {e}")
        return None

def get_or_create_project_context(project_id: str, project_data: dict):
    """Try Supabase; else extract from PDF and store."""
    existing_text = get_project_context(project_id)
    if existing_text:
        return existing_text

    pdf_text = extract_text_from_pdf_field(project_data)
    if pdf_text:
        store_project_context(project_id, pdf_text)
        return pdf_text

    return "No project context available."

def answer_project_question(project_id: str, project_data: dict, question: str) -> str:
    """Use Gemini to answer questions using stored PDF context."""
    pdf_text = get_or_create_project_context(project_id, project_data)

    context = f"""
    You are an academic AI assistant for the Unified Academic Project Portal.

    Project Information:
    Title: {project_data.get('title')}
    Description: {project_data.get('description')}
    Guide: {project_data.get('guideName')}
    Students: {', '.join(project_data.get('students', []))}

    Thesis Text (from PDF):
    ---
    {pdf_text[:8000]}
    ---

    Question: {question}
    """

    model = genai.GenerativeModel("gemini-2.5-flash")
    try:
        response = model.generate_content(context)
        return response.text.strip()
    except Exception as e:
        return f"[AI Error] {str(e)}"
