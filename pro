import openai
import streamlit as st
from streamlit_chat import message

# Setting page title and header
st.set_page_config(page_title="火shan智能问答助手升级版", page_icon="🔥")
st.markdown("火山🔥智能问答助手升级版", unsafe_allow_html=True)

# Initialise session state variables
if 'generated' not in st.session_state:
    st.session_state['generated'] = []
if 'past' not in st.session_state:
    st.session_state['past'] = []
if 'messages' not in st.session_state:
    st.session_state['messages'] = [
        {"role": "system", "content": "You are a helpful assistant."}
    ]
if 'model_name' not in st.session_state:
    st.session_state['model_name'] = []


# Sidebar - let user choose model, show total cost of current conversation, and let user clear the current conversation
st.sidebar.title("侧边栏")
model_name = st.sidebar.selectbox("选择模型:", ("通义千问", "GPT-3.5"))

# Map model names to OpenAI model IDs
if model_name == "GPT-3.5":
    model = "gpt-3.5-turbo"
else:
    model = "qwen-plus"


# generate a response
def generate_response(prompt):
    st.session_state['messages'].append({"role": "user", "content": prompt})

    client = openai.OpenAI(
        api_key="sk-cfc1fae4bbca41c68e844a8a3cf25ac0",
        base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",  # 填写DashScope SDK的base_url
    )
    stream = client.chat.completions.create(
        model="qwen-plus",
        messages=st.session_state['messages']
        )
    response = stream.choices[0].message.content
    st.session_state['messages'].append({"role": "assistant", "content": response})

    return response


# container for chat history
response_container = st.container()
# container for text box
container = st.container()

with container:
    if user_input := st.chat_input("say something..."):
        output = generate_response(user_input)
        st.session_state['past'].append(user_input)
        st.session_state['generated'].append(output)

if st.session_state['generated']:
    with response_container:
        for i in range(len(st.session_state['generated'])):
            message(st.session_state["past"][i], is_user=True, key=str(i) + '_user')
            message(st.session_state["generated"][i], key=str(i))
