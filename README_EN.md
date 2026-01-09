# OnGi – Health Monitoring & Emotional Communication App for Parents and Children

[한국어](./README.md)

<img width="1178" height="785" alt="OnGi_Thumbnail" src="https://github.com/user-attachments/assets/9238452e-313e-43a8-9018-b63846da6716" />

---

Many parents require care due to chronic illness, recovery from accidents, or aging.

However, busy schedules, physical distance, and parents' reluctance to burden their children make it difficult for children to closely monitor their parents' health and emotions.

That's why **'OnGi'** was developed to help you care for your parents' health even from afar.

Parents can easily record their health status, and children can check those records anytime, anywhere.

### **Key Features**

- **Pain Location Recording**: Quickly and easily input where it hurts
- **Medication Check**: Check medication status at a glance
- **Exercise Time Management**: Record exercise time and steps automatically or manually
- **Health Data Sharing**: Check parents' health changes in real-time
- **Daily Photo Sharing**: Promote family communication with one daily photo

When you want to know about your parents' day, when you're worried about their health, **OnGi** brings you closer even from afar.

## 1. Project Introduction

### 1.1. Development Background and Necessity

### Development Background

1. **Increased interest in health with technological advancement**
    - 'Personal Health Care Survey in Asian Countries' published by Royal Philips (Choi Yoonju, 2022)
    - 89% of Koreans recognize the importance of health management.
    - Of the 89%, 51% responded they could more actively practice self-management to maintain health.
    - 57% of Koreans answered that personal health management technology and devices help with better health management.
   
   → People have sufficient interest in health and think positively about management through technology and devices.

2. **Deepening disconnection in intergenerational communication and emotional sharing**
    - Cause 1: Aging society and nuclear families
    - Cause 2: Increasing phenomenon of parents and children becoming physically and emotionally distant

   → A medium is needed to activate intergenerational communication and emotional sharing.

3. **Lack of health-related communication between parents and children**
    - Cause: Disconnection in intergenerational communication and emotional sharing
    - Even when there is willingness to share and discuss health conditions and lifestyle habits, it is often difficult to put into practice.

![Development_Background_Survey_Pie_Chart 1](https://github.com/user-attachments/assets/8d8ba0c2-3ea3-404b-8968-fd350bfc6d4c)

> Parents and children both recognize the importance of health communication with each other.

→ A new form of communication-based health management is needed to turn willingness into action.

### Necessity of Health Communication App

1. **Existing Apps**
    - Existing health management apps<br>
      Mainly focused on simply recording personal data such as blood pressure, sleep, and exercise.
        - Elderly: Difficulty in use
        - Young generation: Lack of interest and sustained motivation
    - Existing communication-centered apps<br>
      Emotional exchange is possible, but it was difficult to achieve both health management and communication.

2. **Why 'OnGi' is needed**

   Health information input and monitoring function (Main) + Communication through everyday and emotional media like photos (Sub) = Promotes family participation and maintains consistent health communication
    - Parents can input their health information, and children can monitor it in real-time.<br>
      → Enables families to be interested in health together.
    - All interactions are converted into a 'Temperature Index' that is visually shared, and when certain levels are reached, it leads to rewards.<br>
      → Transforms health behaviors into daily routines.
      
   → A health communication platform is needed that goes beyond a simple health management tool to restore family warmth.

---

### 1.2. Development Goals and Main Content

### Development Goals

**'OnGi' aims to develop a health monitoring system that can efficiently monitor and care for parents' health even when families are far apart.**

Parents can easily record health information (1. Pain location input, 2. Medication check, 3. Exercise time recording, 4. Step count), and children can check the health records through OnGi.<br>
Additionally, through daily photos uploaded once a day, we aim to develop a service that goes beyond simple health recording to family communication.

### Main Content

OnGi is a service that provides both family health record checking and communication functions. It provides customized services with different UI/UX for parents and children.

#### Customized UI/UX

- Parent Generation
    - **Easy-to-use screen layout** with intuitive and simple design
    - Intuitive temperature index visualization in thermometer form
    - Recording functions for **pain location, medication, exercise time**
    - Medication time alerts and **one-touch check function**
    - **Self-management guidance** through step count and exercise habits

- Child Generation
    - Real-time checking of parents' health status
    - Intuitive temperature index visualization in thermometer form
    - **Medication alert management and pain record viewing** functions
    - **Emotion-based communication** through shared daily photos

### Main Features

#### Health Recording

1. **Pain Location Input Function**
    > Parents can directly select the area where they feel pain and receive stretching video recommendations for that area.<br>Children can check parents' pain records in real-time and respond actively when needed.

2. **Medication Check Function**
    > Push notifications are sent to parents at medication times, and they can record completion by pressing a button.<br>Children can check whether parents took their medication on time through this function.

3. **Exercise Time Recording Function**
    > Users can simply input exercise time for the day to help form exercise habits.

4. **Family Step Counter Function**
    > Visualizes the total family step count for the day by combining all family members' steps.<br>Individual rankings within the family show who walked the most.<br>By comparing and sharing rankings with other families, it encourages healthy competition within families.<br>The focus is not just on competition, but on creating a culture of walking together and cheering each other on.

#### Heart Recording (Communication)
> Users can upload **daily photos** once a day with their emotional state and a comment.<br>
> Family members can view each other's daily life and emotional state in the photo viewing screen.<br>
> Photos are **conditionally viewable** - you must upload your own to see other family members' photos, encouraging mutual participation.

#### Reward System
> Family members can increase the family 'Temperature Index' through app access, health record input/viewing, and communication record participation.<br>
> The accumulated temperature is visually displayed, providing positive feedback to family members,<br>
> and can be converted into physical rewards to encourage continued app use.

### Sustained Use Triggers

1. **'Temperature Index' Visualization and Reward System**
    - Temperature index accumulated through family members' health records, emotional communication, and daily participation
        - Small daily participation is immediately shown as visual changes through donut bars and graphs.
        - Can be exchanged for physical rewards like gift cards or photobooks when certain temperature levels are reached.
    - Structured as [Action → Visual Feedback → Reward → Next Action] to make app use a daily routine.
2. **Step Count Competition Within and Between Families**
    - Provides individual rankings within the family and ranking competition with other families.
        - Encourages a healthy competitive atmosphere and creates a sense of common goal.
3. **Reminder & Notification Functions**
    - Provides app usage reminders through various push notifications including medication reminders, emotion recording reminders, and family participation notifications.
        - Parents take care of their health, children don't miss caregiving.
        - The app functions like a schedule management tool, increasing app access frequency.
4. **Lowered Entry Barriers with Customized UI/UX**
    - Elderly: Minimized app usage discomfort with large text, large buttons, and simple flow.
    - Youth: Increased information immersion through data visualization and detailed features.
    
    → Designed for sustained use by both generations.

### Revenue Structure

- **Subscription Model**: In-app purchase structure based on premium subscription, providing extended features and benefits not available in the free version for **2,900 won/month**.

| Free Users | Paid Users |
|------------|------------|
| Health records viewable for one week | Unlimited health record viewing |
| Medicine registration limited to 3 | Unlimited medicine registration |
| Cannot save or delete heart record photos | Can save and delete heart record photos |


| This app has a 'Premium Subscription System'.<br>How much would you be willing to pay for such paid services and benefits?<br>(Please select on a monthly basis.) |
|:---:|
| <img width="501" height="394" alt="OnGi_Survey xlsx" src="https://github.com/user-attachments/assets/f879fd05-ccdf-465b-8987-2ee5548f9d58" /> |
> Based on survey analysis, it was concluded that pricing between 1,900-3,400 won would be appropriate. Therefore, the paid service price was set at 2,900 won.

- **Partnerships and Advertising**: Collaborate with health foods, health checkups, exercise YouTube channels, etc. to sell affiliated products and content for commission.
- **B2B, B2B2C Contracts**: Enable companies, insurance companies, and local governments to provide OnGi services to employees and subscribers, receiving usage fees.
- **Wearable Bundle**: Bundle sales with wearable devices, allowing bundle purchasers to freely experience paid-only benefits for one year. Share referral fees and joint marketing costs with device sales organizations to reduce cost burden.
  <br/>

---

### 1.3. Target User Analysis

### Survey Overview
- **Survey Period**: August 2-9, 2025 (approximately 7 days)
- **Survey Target**: Ages 20s-60s
- **Sample Size**: Approximately 200 people
- **Survey Purpose**: Analysis of family health management and digital healthcare app acceptance

### Key Survey Results

#### Family Health Interest
- **83%**: Responded that there is **someone who takes care of health** in the family  
→ Overall **interest in family health management is very high**

#### Digital Healthcare App Experience and Acceptance
- **65%**: Have experience using health-related apps  
→ **High experience and acceptance** of digital healthcare solutions
- **Low entry barrier for 'OnGi' app adoption**

#### Parent-Child Health Communication Demand
- From children's perspective: **85%** → Recognize **high interest** in parents' health
- From parents' perspective: **92%** → Recognize **importance of health-related communication** with children
- **Very high bidirectional demand** for health-related conversations

#### App Usage Intent and Market Entry Strategy
- **78%**: **Intent to use** 'OnGi' app
- Of these, **63%**: **Intent to use to manage parents' health from the child's perspective**
- **Market Entry Strategy**: **Bottom-up Strategy**  
  → Initial spread centered on the younger generation → Natural expansion to parent generation afterward

#### Core Feature Preferences
| Rank | Feature | Preference Rate |
|------|---------|-----------------|
| 1 | Parent health monitoring function | **32%** |
| 2 | Parent health management function | **31%** |
| 3 | Family health communication function | **27%** |
| 4 | Family joint participation function | **21%** |

#### Main Reasons for App Usage Intent
- **39%**: Can **easily and appropriately care** for own or parents' health
- **27%**: Possibility of **activating parent-child communication**
- **21%**: **Fun of using together as a family**

### Target User Definition

#### Parent Target
- **Target**: **Middle-aged and elderly** requiring children's care due to chronic illness, accidents, aging, etc.
- **Main Needs**: Health status management, communication with children, prompt care support

#### Child Target
- **Target**: **Young and middle-aged adults** who want to manage their parents' health
- **Main Needs**: Parent health monitoring, efficient management, strengthening family communication

### Insight Summary
- **High-interest group**: High proportion of users active in family health management and communication
- **App usage potential**: 78% usage intent, 65% health app experience → Low entry barrier
- **Market expansion strategy**: **Bottom-up strategy spreading from child generation → to parent generation** is effective
- **Core value proposition**: Service design combining parent health management and family communication needed

---

### 1.4. Differentiation from Existing Services

#### Existing Health Apps
- **Self-health management system, lack of sharing**
  - Designed to encourage individuals to manage their own health, centered on recording biometric data and providing health information.
  - Without special triggers, it's difficult to sustain active use, making it hard to manage overlooked areas or essential shared information.
- **Unidirectional flow of functions**<br>
  Because it tends to focus on medical-centered information and statistics-based numbers, it leads to 'Record - View - Notification' rather than user interaction.
- **Heavy approach to 'health' topic due to lack of interest-generating elements**
    - Family unit users: Even recognizing functional usefulness, it's difficult to sustain long-term use.
    - Elderly: Digital entry barriers exist due to complexity.
    - Young generation: Emotional motivation to continue using in daily life is not provided.

#### Differentiation from Existing Services
1. **Implementing 'Simultaneity' of Health Management and Family Communication**
    - A hybrid form combining health functions, communication functions, and game elements targeting gaps in the current market.
    - Parent health input and child monitoring functions conducted at the family level, along with step counter competition functions, simultaneously satisfy health management and emotional communication between families.<br>
   → Implements participation-based relationship-strengthening UX beyond the limitations of one-way health management apps

2. **'Temperature Index' System Visualizing Connection Between Health Activities and Emotions**
    - The visualized 'Temperature Index' connects beyond simple recording to emotional responses, naturally allowing families to feel warm interactions.<br>
   → Overcomes invisible communication aspects in existing apps and information provision that may feel like simple feedback
    - Families have common goals.<br>
   → Connected to strengthening positive interdependence among family members
    - When 'Temperature Index' above certain standards is accumulated, rewards like gift cards and family photo albums (composed of photos uploaded to OnGi app) can be received.<br>
   → Offsetting app usage attrition through reward system<br>
   → Triggers long-term usage retention by providing experience of small achievements accumulating daily

3. **Mutual Conditional Design of Photo and Emotion Upload**
    - Uploading photos and emotions is not mandatory, but if you want to see photos uploaded by other family members, you must first upload your own photo.
    - Creates exchange based on mutual participation, not one-way consumption.
    - Converts users who just 'lurk' into active participants to maintain communication balance.

   → Photos and emotion exchange trigger functional health behaviors (health recording and monitoring) in a virtuous cycle

4. **Senior-Friendly UI**
    - Users registering as parents are likely to be digitally vulnerable, so input methods with reduced cognitive burden are provided through app tutorials, large text, large record buttons, and minimum touch flow.


---

### 1.5. Social Value Introduction Plan
1. Social Contribution (What)
    - **Health Management Aspect**
        - Parent health recording and notification functions increase the probability of early detection and prevention of health abnormalities.<br>
          (e.g., In beta testing with app MVP, 80% of children responded they could learn about previously unknown parental health conditions)
        - Efficiency of health management can be enhanced through integration with wearable devices like smartwatches.
        - Medical cost reduction effects can be expected.
    - **Emotional Communication Aspect**
        - Photo and emotion sharing and family unit temperature index system strengthen family bonds by providing experiences of achieving together.
    - **Digital Inclusion**
        - Intuitive UX/UI enables easy use by the elderly.
        - Can bridge generational digital gaps and expand accessibility for people of various ages and environments.
2. Expansion Plan (How)
    - **Regional Partnerships**: Distribute the app through collaboration with health centers and welfare centers.
    - **Educational Support**: Support youth/university volunteer groups or city-hosted support activities and education to be smoother. (e.g., City-sponsored 'Smartphone Classes')
    - **Corporate/Public Utilization**: Contribute to society through campaigns linked with welfare programs and health insurance.
3. Final Expected Effects
    - **Individual Level**: Manage health and strengthen family communication.
    - **Household Level**: Alleviate caregiving burden and naturally improve relationships among members.
    - **Social Level**: Can lead to medical cost reduction, welfare supplementation, and recovery of community as a whole.
      <br/>

## 2. Detailed Design

### 2.1. System Architecture

#### **Full-Stack Architecture**

<img width="851" height="758" alt="image 2" src="https://github.com/user-attachments/assets/95fdc614-bbe5-4294-97c9-98bac7dcac65" />

#### **ERD**

<img width="2559" height="2264" alt="image 3" src="https://github.com/user-attachments/assets/9d4d2a02-37f2-4229-8a20-75fcbe4b92a4" />

<br/>

### 2.2. Technologies Used

- **Frontend**
    - Flutter - 3.35.1
    - fastlane
- **Backend**
    - Spring Boot - 3.5.3 / Java 21
    - MySQL - 8.4.6
- **Infrastructure**
    - AWS - AppRunner, RDS, S3
    - FCM, APNs
    - Github Actions
    - CodeRabbit
- **Designer**
    - Figma
    - Adobe Illustrator
- **Collaboration / Schedule Management**
    - Notion
    - Github / Git
    - CodeRabbit
    - Jira
      <br/>

## 3. Development Results

### 3.1. Overall System Flow

- Components
<img height="200" alt="Flow_Chart_Whiteboard_in_Red_Blue_Basic_Style_(2)" src="https://github.com/user-attachments/assets/3eed7577-37cf-4a92-9eca-111e62dc0ed6" />

<br><br>

- Overall Flow (+Login/Signup)
<img height="1300" alt="Flow_Chart_Whiteboard_in_Red_Blue_Basic_Style_(3)" src="https://github.com/user-attachments/assets/388875d4-dc06-477e-8285-ddc4e0f0b88c" />

<br><br>

- Home Page<br><br>
<img height="600" alt="Flow_Chart_Whiteboard_in_Red_Blue_Basic_Style_(9)" src="https://github.com/user-attachments/assets/e283ab9c-ca16-492d-b4a4-e81950b260a4" />

<br>

- Health Record Page<br><br>
<img height="900" alt="Flow_Chart_Whiteboard_in_Red_Blue_Basic_Style_(10)" src="https://github.com/user-attachments/assets/ac2135e4-8522-4b2f-b4d1-47fcd1366cf4" />

<br>

- Heart Record Writing Page<br><br>
<img height="500" alt="Flow_Chart_Whiteboard_in_Red_Blue_Basic_Style_(6)" src="https://github.com/user-attachments/assets/790a46ca-7e86-4fdd-83f9-4c40c288278a" />

<br><br>

- Heart Record Album<br><br>
<img height="600" alt="Flow_Chart_Whiteboard_in_Red_Blue_Basic_Style_(7)" src="https://github.com/user-attachments/assets/8d14ab59-3468-47b3-a067-332b41ce937b" />

<br><br>

- My Page<br><br>
<img height="300" alt="Flow_Chart_Whiteboard_in_Red_Blue_Basic_Style_(8)" src="https://github.com/user-attachments/assets/15131d0d-f230-4bff-9638-623439d1ae67" />

---

### 3.2. Feature Description

#### **3.2.1. Onboarding Page**

- Email Input
    - Clicking the **Start button** displays a welcome text, then moves to the email input page after 3 seconds.
    - After entering the email in the input field, clicking the **Continue button** performs email validation.
    - If email validation fails, a warning message is displayed at the bottom.
    - If email validation passes, it checks if an account with that email exists.
    - If an account exists, move to the login page (3.2.3).
    - If no account exists, move to the signup page (3.2.2).

#### **3.2.2. Signup Page**

- Password Input
    - After entering a password, clicking the **Signup button** checks if the password is at least 8 characters.
    - Password field content is masked by default; clicking the eye button shows the content.
    - If less than 8 characters, a warning message is displayed at the bottom.
    - If 8 or more characters, move to the nickname input screen.
- Nickname Input
    - Enter desired nickname and click **Continue button** to move to profile icon selection screen.
- Profile Icon Selection
    - Clicking a desired icon from 9 options shows a check icon.
        - With an icon selected, clicking **Register button** moves to mode selection screen.
        - Clicking **Register button** without selecting an icon shows a warning message.
- Mode Selection
    - Select whether the user is a parent or child by clicking a button.
    - Clicking a button moves to the family name input screen.
- Family Name Input
    - For first-time family registration, enter a family name in the input field.
    - Entering a family name automatically generates a family code and moves to the landing page.
    - If there's an existing family, click the checkbox below the input field to move to family code input screen.
- Family Code Input
    - Enter the family code and click **Join button** to validate if the family exists.
    - If validation fails, a warning message is displayed.
    - If validation passes, move to the landing screen.
- Landing
    - Clicking **Ready! button** moves to the tutorial page (3.2.21).

#### **3.2.3. Login Page**

- Password Input
    - Enter password and click **Login button** to verify if the email and password match.
    - Password field content is masked by default; clicking the eye button shows the content.
    - If matching and user is a parent, move to parent landing page (3.2.4).
    - If matching and user is a child, move to main page (3.2.5).
    - If not matching, a warning message is displayed.

#### **3.2.4. Parent Landing Page**

- Click the **left health record button** to move to health record main page (3.2.9).
- Click the **right home button** to move to main page (3.2.6).

(* This page is designed for digitally vulnerable parents, with large health record and home buttons for easy access to main screens.)

#### **3.2.5. Navigation Bar**

- Click the first **home icon** on the left to move to main page (3.2.6).
- Click the second **health record icon** on the left to move to health record main page (3.2.9).
- Click the center **plus icon** to move to heart record input page (3.2.17).
- Click the first **album icon** on the right to move to heart record view page (3.2.18).
- Click the second **my page icon** on the right to move to my page (3.2.20).

#### **3.2.6. Main Page**

- User nickname is displayed in the upper left.
- There's a **reward button** in the upper right; clicking it moves to reward page (3.2.8).
- A **donut graph** showing family temperature is in the center left; clicking it moves to temperature graph page (3.2.7).
- On the right is a **medication, health status, step count sidebar**; clicking it shows today's medications, selected body parts, and step count.

#### Demo Videos
|<video src="https://github.com/user-attachments/assets/41a57ff7-67d6-4dd9-b5f8-a0a427340617">|<video src="https://github.com/user-attachments/assets/24b68e7f-daab-45df-91f5-b3315af7955a">|<video src="https://github.com/user-attachments/assets/346b30b3-b7f4-4283-abec-e1071638d487">|<video src="https://github.com/user-attachments/assets/876aa4ff-d97a-4391-97e9-60d9947ec8f7">|
|:--:|:--:|:--:|:--:|
|3.2.1. Onboarding Page<br>3.2.2. Signup Page|3.2.3. Login Page|3.2.4. Parent Landing Page<br>3.2.6. Main Page<br>3.2.21. Tutorial Page|3.2.5. Navigation Bar|
|<video src="https://github.com/user-attachments/assets/4293ce57-6a2b-4145-8247-d94eea8d7623">|<video src="https://github.com/user-attachments/assets/b1e2483b-8f2e-4cd4-8b3d-626aa0a62ca1">|<video src="https://github.com/user-attachments/assets/4aba9005-9801-424e-bd43-8a3a0bc510f9">|<video src="https://github.com/user-attachments/assets/b8c91178-440c-4fea-b68d-31ecbedc3547">|
|3.2.8. Reward Page|3.2.9. Health Record Main Page (Parent)<br>3.2.10. Health Status Record Page|3.2.9 Health Record Main Page (Child)|3.2.11. Medication Page|
|<video src="https://github.com/user-attachments/assets/bb48e2e4-89c6-453e-81ca-b5e0b929fb0d">|<video src="https://github.com/user-attachments/assets/2ae5bca7-7c45-4652-8252-02fa7b99ca77">|<video src="https://github.com/user-attachments/assets/6a7f6c30-9939-4e04-8a88-ac6a3111e87f">|<video src="https://github.com/user-attachments/assets/11362522-5227-4e97-9ba6-d2c3f6ade7c0">|
|3.2.13. Exercise Time Summary Page<br>3.2.14. Exercise Time Record Page|3.2.15. Step Count Page<br>3.2.16. Step Count Competition Page|3.2.17. Heart Record Input Page<br>3.2.18. Heart Record View Page<br>3.2.19. Heart Record Detail Page|3.2.20. My Page|

--- 

### 3.3. Feature Specifications

- Splash Screen<br>
<img height="400" alt="Splash" src="https://github.com/user-attachments/assets/224f2baf-5cd7-47db-9b71-448c7b1c30e6" />

- Start Page<br>
<img height="400" alt="Common_-_Start1" src="https://github.com/user-attachments/assets/5bbd8ed5-527f-472e-b2b5-399ea7a0e777" />
<img height="400" alt="Common_-_Start3" src="https://github.com/user-attachments/assets/3f4f0830-58b2-482b-957c-d690e388d7f8" />

| **Label** | **Name** | **Details** |
|--------|-----------|----------------------------------------------------------------------------------------|
| 1 | Initial Start Button | Leads to login/signup logic |
| 2 | Email Input | Enter in valid email format |
| 3 | Email Input Button | Checks if email is already registered<br/>- Unregistered email: Landing to signup page (4)<br/>- Registered email: Landing to login page (16) |

- Signup Page<br>
<img height="400" alt="Common_-_Signup1" src="https://github.com/user-attachments/assets/1a079bca-5957-4fcb-920a-d746fd722982" />
<img height="400" alt="Common_-_Signup2" src="https://github.com/user-attachments/assets/35429e6b-e867-491c-82b8-15ad64d56e97" />
<img height="400" alt="Common_-_Signup3" src="https://github.com/user-attachments/assets/1af38cb4-622b-4c07-b1e1-a492de9b343d" />
<img height="400" alt="Common_-_Signup4" src="https://github.com/user-attachments/assets/10ef1cf5-433c-4d54-9164-b36dc6d34806" />
<img height="400" alt="Common_-_Signup5" src="https://github.com/user-attachments/assets/fbcb7f69-6345-4566-ad08-edba6292a160" />
<img height="400" alt="Common_-_Signup6" src="https://github.com/user-attachments/assets/b1c38ca0-cdbe-4660-9fef-3165269bac68" />
<img height="400" alt="Common_-_Signup7" src="https://github.com/user-attachments/assets/b4a23a72-6e57-46a5-ab5a-230a71b77910" />

| **Label** | **Name** | **Details** |
|--------|-------------------|-----------------------------------------------------------------------------------------------|
| 4 | Password Input | Enter password for account registration |
| 5 | Signup Button | Save account info to DB |
| 6 | Nickname Input | Enter nickname to use |
| 7 | Icon Selection | Select profile icon |
| 8 | Role Selection | Select whether to use app as parent/child |
| 9 | Family Name Input | Enter family name to use |
| 10 | Existing Family Check | Check if there's already a registered family |
| 11 | Family Creation | Family creation complete |
| 12 | Family Code Generate/Input Button | Depending on (10) check,<br>- If already have family with code: Input family code<br>- If creating family for first time: Auto-generate family code |
| 13 | Signup Complete | Landing to home page |

- Login Page<br>
<img height="400" alt="Common_-_Login1" src="https://github.com/user-attachments/assets/6594550e-f72f-45d8-9f9a-d5d2064da97b" />
<img height="400" alt="Common_-_Login2" src="https://github.com/user-attachments/assets/be7734fd-cabc-4b29-9e31-de4e2535181c" />

| **Label** | **Name** | **Details** |
|--------|---------|------------------|
| 14 | Password Input | Enter previously registered password |
| 15 | Login Complete | Landing to home page |

- Home Page<br>
<img height="400" alt="Common_-_Home Large" src="https://github.com/user-attachments/assets/bef4ca72-fbfd-4ad3-97a2-1d02ba848ee9" />
<img height="400" alt="Common_-_Home_-_Reward" src="https://github.com/user-attachments/assets/307cd4c2-b1e3-44b2-ab48-4f41d72c1566" />
<img height="400" alt="Common_-_Home_-_TempGraph" src="https://github.com/user-attachments/assets/444d49c7-001a-4f35-8a31-52b0bd1fdf02" />
<img height="400" alt="Common_-_Home_-_TempGraph-1" src="https://github.com/user-attachments/assets/74256919-3717-4633-83b4-01bbca466d56" />

| **Label** | **Name** | **Details** |
|--------|----------------------|----------------------------------------------------------------------------------|
| 1 | Navigation Bar - Home | Home page navigation |
| 2 | User Display | Shows user's profile icon and nickname |
| 3 | Reward Button | Landing to reward page (4~6) |
| 4 | Available Temperature Display | Available temperature<br>- Family temperature index minus base temperature 36.5°C |
| 5 | Heart Album Exchange Event | Event to convert heart album to physical photo book when reaching 300°C |
| 6 | Exchangeable Gift Card List | Exchange temperature set proportionally to physical gift card prices |
| 7 | Family Temperature Index Display | Shows family's accumulated temperature index |
| 8 | Temperature Index Donut Graph | - Shows each member's contribution to family temperature as donut graph<br>- Clicking donut graph lands to temperature detail page (9~11) |
| 9 | Temperature Index Line Graph | Shows family temperature index changes over last 5 days |
| 10 | Expand Contribution History Button | Click to see detailed contribution history |
| 11 | Temperature Contribution History | Last 7 days of family contributions |
| 12 | Sidebar 1 | Medication time quick notification |
| 13 | Sidebar 2 | Pain location quick notification |
| 14 | Sidebar 3 | Step count quick notification |


- Health Record Page - Main
    - Parent (left), Child (right)<br>
<img height="400" alt="Parent_-_HealthRecord" src="https://github.com/user-attachments/assets/fb3952ca-a218-46d8-878a-2cee7b5d919e" />
<img height="400" alt="Child_-_HealthRecord" src="https://github.com/user-attachments/assets/3c63c40a-261d-4af4-bae8-2f6a0541e618" />


| **Label** | **Name** | **Details** |
|--------|-----------------|------------------------------------------------------|
| 1 | Navigation Bar - Health Record | Health record page navigation |
| 2 | Parent Screen | Parent records health status on each detail page |
| 3 | Child Screen | Child can:<br>- Select parent to monitor<br>- View parent's health records |
| 4 | Pain Location Record Page Button | Landing to pain location record page |
| 5 | Medication Page Button | Landing to medication page |
| 6 | Exercise Time Record Page Button | Landing to exercise time record page |
| 7 | Step Counter Page Button | Landing to step counter page |
| 8 | Step Counter Ranking Page Button | Landing to step counter ranking page |

- Health Record Page - Pain Location<br>
<img height="400" alt="Parent_-_HealthRecord_-_HealthStatus_Input(Front)" src="https://github.com/user-attachments/assets/e4c5dcb2-4dda-4d30-aabb-848d840a0389" />
<img height="400" alt="Parent_-_HealthRecord_-_HealthStatus_Input(Back)" src="https://github.com/user-attachments/assets/d3b771b5-d5eb-4269-9f90-f690f79f5827" />
<img height="400" alt="Parent_-_HealthRecord_-_HealthStatus_Input1" src="https://github.com/user-attachments/assets/a314d80b-1a78-479d-a3bc-ff834e2ef4a9" />
<img height="400" alt="Parent_-_HealthRecord_-_HealthStatus_Input(Front)-1" src="https://github.com/user-attachments/assets/ee9bd0c8-2875-4625-987a-7d0c696a5355" />

| **Label** | **Name** | **Details** |
|--------|-------------|----------------------------------------------------------------------------------------------------------------------|
| 1 | Date Selection | Record/view by date |
| 2 | Pain Location Selection | Can select each body part on body diagram<br>- Front/back toggle allows separate selection of chest/back/abdomen/pelvis/buttocks<br>- Body parts subdivided into left/right and detailed parts (shoulder/upper arm/forearm/hand/thigh/calf/knee/foot etc) |
| 3 | Front Body Diagram Button | Click to switch to back body diagram |
| 4 | Back Body Diagram Button | Click to switch to front body diagram |
| 5 | Selection Complete Button | - Activates in orange when pain location selected<br>- Click lands to confirmation message (6) |
| 6 | Confirmation Message | Can verify selected locations |
| 7 | Stretching Video Provision | Provides stretching video matching selected pain location after recording |

- Health Record Page - Medication<br>
<img height="400" alt="Parent_-_HealthRecord_-_Medication" src="https://github.com/user-attachments/assets/14fa700c-5c68-4f8a-83df-8f0ee87dfac0" />
<img height="400" alt="Common_-_HealthRecord_-_Medication_-_AddMed-1" src="https://github.com/user-attachments/assets/5725d53d-64ee-40f7-9b11-d697f35469ba" />
<img height="400" alt="Common_-_HealthRecord_-_Medication_-_AddMed" src="https://github.com/user-attachments/assets/cdd8961e-9c7a-4d0d-8ca9-0258e44ecd5d" />

| **Label** | **Name** | **Details** |
|--------|-------------|----------------------|
| 1 | Date Selection | Record/view by date |
| 2 | Medicine Info | Can check medicine name, dosage time |
| 3 | Dosage Check Button | Can check dosage status |
| 4 | Add Medicine Button | Landing to add medicine detail page (5~10) |
| 5 | Medicine Photo Registration | Can add from gallery |
| 6 | Medicine Name Registration | - |
| 7 | Dosage Day Registration | - |
| 8 | Dosage Frequency Registration | - |
| 9 | Dosage Time Registration | - |
| 10 | Before/After Meal Interval Registration | - |

- Health Record Page - Exercise Record<br>
<img height="400" alt="Parent_-_HealthRecord_-_ExerciseTime1" src="https://github.com/user-attachments/assets/9be38fb7-56a3-44af-a677-73269b2173f2" />
<img height="400" alt="Parent - HealthRecord - ExerciseTime2" src="https://github.com/user-attachments/assets/9b26126c-d8b7-4951-97b0-9b71eb6a66c3" />


| **Label** | **Name** | **Details** |
|--------|----------|------------------------------------------------|
| 1 | Date Selection | Record/view by date |
| 2 | Exercise Time Display | - Shows recorded exercise time<br>- Click moves to exercise time record page (3) |
| 3 | Exercise Time Record | Can record exercise time in 10-minute units |

- Health Record Page - Family Step Counter<br>
<img height="400" alt="Parent_-_HealthRecord_-_FamilyStepCounter" src="https://github.com/user-attachments/assets/f736b804-a0d9-4644-83b8-f95854a5e3af" />

| **Label** | **Name** | **Details** |
|--------|---------|--------------------------------------|
| 1 | Date Selection | View step count by date |
| 2 | Step Count View | - Can view family members' step counts<br>- Crown displayed on 1st place |

- Health Record Page - Step Counter Ranking<br>
<img height="400" alt="Parent_-_HealthRecord_-_FamilyStepCounter_Ranking" src="https://github.com/user-attachments/assets/83403bb1-99a3-4acc-a679-25baf7ba913d" />

| **Label** | **Name** | **Details** |
|--------|---------------|----------------------------------------------------------------------------|
| 1 | Family Average Step Count | Can view family average step count for the week's 7 days |
| 2 | Family Step Counter Ranking | - Can view family's step counter ranking among all user families<br>- Bonus points awarded for top 10%, 20% |

- Heart Record Page<br>
<img height="400" alt="Common_-_Photo_and_Heart_Add2" src="https://github.com/user-attachments/assets/c8e1591b-e749-46da-9e63-6816c87e45ad" />
<img height="400" alt="Common_-_Photo_and_Heart_Add2-1" src="https://github.com/user-attachments/assets/30b9044c-18d0-4b18-9ce6-b37af67a1525" />
<img height="400" alt="Common_-_Photo_and_Heart_Add3" src="https://github.com/user-attachments/assets/1ca57563-bb64-424d-bb4c-ffade6362248" />
<img height="400" alt="Common_-_Photo_and_Heart_Add4" src="https://github.com/user-attachments/assets/9ddf02f4-02f6-4f31-b8cd-20e8e2aefb5c" />
<img height="400" alt="Common_-_Photo_and_Heart_Add5" src="https://github.com/user-attachments/assets/32e54fa1-19fb-45a5-bb01-207b08324fe5" />

| **Label** | **Name** | **Details** |
|--------|-------------|---------------------------------------------------------------------------------------------------|
| 1 | Rear Photo Capture | 3-second countdown starts after capture |
| 2 | 3-Second Countdown | Front photo capture after 3 seconds |
| 3 | Front Photo Capture | Encourages face photo → enables more effective sharing of each other's well-being |
| 4 | Location Display | Shows photo capture location |
| 5 | Photo Register Button | - |
| 6 | Heart Record Date Display | Shows date of record |
| 7 | Emotion Keyword Selection | Select emotion felt today |
| 8 | Message Writing | Write loving message to convey to family |
| 9 | Heart Record Complete | Landing to confirmation page (10, 11) |
| 10 | Confirmation Page 1 | When family member(s) other than me have left heart record<br>- Click "Go See" button<br>- Move to heart album page |
| 11 | Confirmation Page 2 | When no family members other than me have left heart record<br>- Click "Urge" button<br>- Can send urge notification to family members<br>- Heart album |

- Heart Album<br>
<img height="400" alt="Common_-_HeartRecord_Album" src="https://github.com/user-attachments/assets/0ca24e55-f95b-46b1-9c8b-f3df19e5f68e" />
<img height="400" alt="Common_-_HeartRecord_Album_-_Detail" src="https://github.com/user-attachments/assets/aafbb261-8c2c-42cc-9313-c69280180649" />
<img height="400" alt="Common_-_HeartRecord_Album_-_Detail-1" src="https://github.com/user-attachments/assets/5025e11a-9211-4560-a9a9-6f10c49b287c" />
<img height="400" alt="Common_-_HeartRecord_Album_-_Detail-2" src="https://github.com/user-attachments/assets/56163e6a-9573-4690-910c-a7e0895e03ae" />

| **Label** | **Name** | **Details** |
|--------|-----------------|--------------------------------------------------------------------------------|
| 1 | Navigation Bar - Heart Album | Heart album page navigation |
| 2 | Heart Record Calendar Display | - Can see heart record status at a glance<br>- Selecting specific date lands to detail page (4, 5, 6) |
| 3 | Heart Record Count Display | 4 circles fill sequentially based on ratio of family members who recorded |
| 4 | Detail Page 1 | When me + other family have left heart record<br>- Can see all records without blur |
| 5 | Detail Page 2 | When I haven't left heart record<br>- Other family's records are blurred<br>- Must leave my record to see other family's records |
| 6 | Detail Page 3 | When no one has left heart record |
| 7 | Heart Record Display | Can see photos uploaded by family and messages to convey |
| 8 | Emotion Keyword Display | - |

- My Page<br>
<img height="400" alt="Common_-_MyPage" src="https://github.com/user-attachments/assets/25e4b2c0-26df-4579-a9d2-8e1764ebb940" />


| **Label** | **Name** | **Details** |
|--------|-------------|--------------------|
| 1 | Family Code Copy Button | Can easily copy family code |
| 2 | Profile Edit Button | Landing to profile edit page |
| 3 | Logout Button | - |


---

### **3.4. Expert Feedback Implementation**

Service core features were strengthened based on expert feedback. The table below summarizes key feedback and implementation results.

| **Feedback Item** | **Implementation Result** |
|--------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
| **Family Step Counter Ranking System** | - Designed for competition with other user families based on **weekly average step count** per family<br>- **Additional temperature index awarded** to families in **top 20%** weekly ranking to increase motivation and participation |
| **KakaoTalk Health Analysis Report Sharing Feature** | Implemented to **auto-generate weekly/monthly health analysis reports** for **easy sharing with other family members via KakaoTalk** |
| **Wearable and Healthcare Integration** | Currently only collecting step count information; plan to **systematically and automatically collect/analyze health data** through integration with Google Fit, Samsung Health (Galaxy Watch), Apple Health (Apple Watch) in the future |


| <img height="800" alt="Parent_-_HealthRecord_-_FamilyStepCounter_Ranking 1" src="https://github.com/user-attachments/assets/94a59518-cbb4-486b-a871-0febb8ae4f7c" /> | <img height="800" src="https://github.com/user-attachments/assets/1c339f12-70ee-4511-9b62-d948eb7f1b1c" /> |
|:------------------------------------------------------------------------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------------------------------------:|
| [Screen 1] Family Step Counter Ranking System Screen | [Screen 2] KakaoTalk Health Analysis Report Sharing |

---

### 3.5. Directory Structure

- Backend

    ```
    ongi
    ├── gradle/                             # Gradle configuration folder
    └── src/
        ├── main/
        │   ├── java/
        │   │   └── ongi/
        │   │       ├── auth/               # Authentication and token related features
        │   │       │   ├── controller/     # API endpoints
        │   │       │   ├── dto/            # Request/Response DTOs
        │   │       │   ├── service/        # Business logic
        │   │       │   └── token/          # Token management
        │   │       │       ├── entity/     # DB mapping entities
        │   │       │       ├── repository/ # DB access layer
        │   │       │       └── util/       # Related utilities
        │   │       ├── common/             # Common class collection
        │   │       │   ├── dto/            # Common DTOs
        │   │       │   └── entity/         # Common entities
        │   │       ├── exception/          # Global exception handling and custom exceptions
        │   │       ├── family/             # Family related feature handling
        │   │       │   ├── controller/
        │   │       │   ├── dto/
        │   │       │   ├── entity/
        │   │       │   ├── repository/
        │   │       │   ├── service/
        │   │       │   └── support/        # Family related support classes
        │   │       ├── firebase/           # Firebase (FCM) related configuration
        │   │       ├── health/             # Health record related features
        │   │       │   ├── controller/
        │   │       │   ├── dto/
        │   │       │   ├── entity/
        │   │       │   ├── repository/
        │   │       │   └── service/
        │   │       ├── maum_log/           # Heart record related features
        │   │       │   ├── controller/
        │   │       │   ├── dto/
        │   │       │   ├── entity/
        │   │       │   ├── enums/          # Emotion state Enum
        │   │       │   ├── repository/
        │   │       │   └── service/
        │   │       ├── pill/               # Medication management features
        │   │       │   ├── controller/
        │   │       │   ├── dto/
        │   │       │   ├── entity/
        │   │       │   ├── repository/
        │   │       │   └── service/
        │   │       ├── security/           # Spring Security configuration and filters
        │   │       ├── step/               # Family step count related features
        │   │       │   ├── controller/
        │   │       │   ├── dto/
        │   │       │   ├── entity/
        │   │       │   ├── repository/
        │   │       │   └── service/
        │   │       ├── temperature/        # Family temperature related features
        │   │       │   ├── controller/
        │   │       │   ├── dto/
        │   │       │   ├── entity/
        │   │       │   ├── repository/
        │   │       │   └── service/
        │   │       ├── user/               # User management features
        │   │       │   ├── controller/
        │   │       │   ├── dto/
        │   │       │   ├── entity/
        │   │       │   ├── repository/
        │   │       │   └── service/
        │   │       └── util/               # Common utility classes (S3 etc)
        │   └── resources/                  # Configuration and resource files
        └── test/
            ├── java/
            │   └── ongi/                   # Test code
            └── resources/                  # Test resources
    ```

- Frontend

    ```
    ongi
    ├── android/                 # Android native project folder
    ├── build/                   # Build output directory
    ├── ios/                     # iOS native project folder
    ├── test/                    # Test code folder
    ├── analysis_options.yaml    # Code analysis and lint rules config file
    ├── devtools_options.yaml    # Flutter DevTools config file
    ├── firebase.json            # Firebase config file
    ├── pubspec.lock             # Dependency version lock file
    ├── pubspec.yaml             # Project main config file
    ├── assets/                  # Static resources folder (fonts, images, etc)
    │   ├── fonts/               # Font resources folder
    │   └── images/              # Image resources folder
    │       ├── reward_products/ # Reward images folder
    │       ├── tutorials/       # Tutorial screen images folder
    │       └── users/           # User icon images folder
    └── lib/                     # Main source code folder
        ├── core/                # Core components folder (global settings, constants, themes, etc)
        ├── models/              # Data model definition folder
        ├── screens/             # Screen (UI) related code folder
        │   ├── health/          # Health record related screen (UI) code folder
        │   ├── home/            # Home screen code folder
        │   ├── login/           # Login related screen (UI) code folder
        │   ├── mypage/          # My page screen (UI) code folder
        │   ├── photo/           # Heart record related screen (UI) code folder
        │   ├── signup/          # Signup related screen (UI) code folder
        ├── services/            # Service logic code folder
        ├── utils/               # Common utility functions and helper classes folder
        └── widgets/             # Widget component code folder
    ```

<br/>

---

## 4. Installation and Usage

- iOS: Install via TestFlight
- Android: Install via Google Play Store or APK file
  
|                                     ![ios QR](https://github.com/user-attachments/assets/8a11807e-de17-45dd-884a-71b05cbcf6db)                                      |                                                                ![android QR](https://github.com/user-attachments/assets/1c062370-d12d-406a-a8c5-05cd494f1178)                                                                |                                               ![android apk QR](https://github.com/user-attachments/assets/c4a8de56-6f0d-4550-b118-b3883d23ebc8)                                                |
|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| [<img height="50" alt="image" src="https://github.com/user-attachments/assets/f0142e99-1a46-4d57-ab86-7ca4aef3596c" />](https://testflight.apple.com/join/ywaeumFn) | [<img height="50" alt="GetItOnGooglePlay_Badge_Web_color_English" src="https://github.com/user-attachments/assets/2e88def4-7311-4663-af88-016e77260517" />](https://play.google.com/store/apps/details?id=com.ongi2025.ongi) | [<img height="50" alt="download-android-apk-badge-seeklogo" src="https://github.com/user-attachments/assets/805f1362-4fd2-46e3-81fb-97dcd87b2d9b" />](https://statics.jun0.dev/app-release.apk) |

### Manual Build

> Firebase configuration files are not included in the repository.<br>
> For manual build, you need to add the following files separately.

- Android → `android/app/google-services.json`
- iOS → `ios/Runner/GoogleService-Info.plist`

#### 1. Install Dependencies

```bash
flutter pub get
cd ios && pod install && cd ..
```

#### 2. Android Release Build

```bash
# Generate AAB
flutter build appbundle --release

# Generate APK
flutter build apk --release
```

#### 3. iOS Release Build (macOS only)

```bash
flutter build ios --release
```

<br/>

## 5. Introduction and Demo Video
[<img width="700px" alt="Introduction and Demo Video" src="https://github.com/user-attachments/assets/c3a1f398-bd85-440b-8480-2e2b30355244" />](https://youtu.be/b4rGJLy9ngk)

<br/>

## 6. Results and Test Outcomes

### 6.1. Test Scenario, Participants, and Period

Tests were conducted to verify that the service operates normally and that users promote active participation in family health management and emotional communication through 'OnGi'.

- **Test Period**: 8/11(Tue) - 8/17(Sun); conducted over 6 days
- **Participants**: A total of 6 households of project team members' families
- **Scenario**
    - Users: Parents/Children in the household
    - Actions
        - Parents record their health status, and children check the records.
        - Share each other's daily lives easily through the daily photo sharing function.
        - Record health and daily photos, and confirm that the family 'Temperature Index' changes according to the records.

### 6.2. Conclusions Based on Feedback and Reviews

Test results confirmed that all participating families found the service operating normally, and that 'OnGi' facilitated family health management and emotional communication to some extent.

In particular, it was highly valued that parents can easily convey their records through the app without directly stating their health condition. Also, through health records and daily photo sharing functions, interest and communication among family members naturally increased.

Key findings from feedback:

- Health status recording and daily sharing functions were intuitive and easy to use, allowing all family members to participate without burden.
- Seeing the 'Temperature Index' change visually confirmed results of recording, positively affecting participation motivation.
- Parents found that knowing their children were checking records made them more consciously take vitamins or exercise that they might otherwise overlook.
- Some users suggested that UI guidance during photo upload could be clearer.

As a result, this test confirmed that **the basic functions operate as intended and are effective in promoting health management and emotional communication among families**. Particularly, the ability to naturally encourage family members to observe and participate in each other's health behaviors is considered a meaningful achievement.

## 7. Expected Effects and Utilization Plans

### 7.1. Effects for Users

1. Health Management Effects
    - **Early detection of abnormal signs**: By integrating data input manually or through wearables, pattern changes are detected and users are notified, encouraging preventive management such as hospital visits. At the social level, this brings positive effects of 'medical cost reduction' and 'spreading preventive health management culture'.
    - **Lifestyle improvement**: Daily goal achievement is gamified, and temperature index rewards through family mutual encouragement strengthen continued use.
    - **Caregiving burden distribution**: Since parents' status is shared by the whole family, the phenomenon of caregiving being concentrated on specific members is alleviated.
    - **Relieving the burden of sharing health status**: Parents can indirectly reveal painful areas, making it easier to share health status. This alleviates the burden of thinking they're burdening their children by revealing pain.
2. Emotional/Relational Effects
    - **Increased communication frequency**: Creates natural conversation triggers through photo and emotion sharing, and rules that require uploading your own photos to see others'.
    - **Emotional stability**: Parents experience psychological stability knowing someone is watching over them; children experience reduced worry and uncertainty about parents.
    - **Generational digital inclusion**: Senior-friendly UI (large text, large record buttons, minimum touch flow) reduces digital gap.

### 7.2. Future Utilization Plans and Business Model

1. Future Utilization Plans
    - **Individuals and Families (B2C)**
        - Wearable integration expansion: Increase accessibility to information by compatibility with various devices like Google Fit, Samsung Health (Galaxy Watch), Apple Health (Apple Watch).
        - Family challenge expansion: Provide more entertainment using 'Temperature Index' and 'step counter functions' that can be used as challenge elements, and encourage family participation.
    - **Enterprise (B2B, B2B2C)**
        - Corporate welfare: Provide service as one of 'parent health management support' packages to employees to strengthen productivity and well-being.
        - Insurance company programs: Can be combined with preventive management-based insurance product discounts.
        - Medical welfare linkage: Provide OnGi's dashboard to chronic disease management or elderly living alone care programs to assist progress.
    - **Public and Regional (B2G)**
        - Regional program linkage: Eliminate blind spots in care by linking with specific local government welfare centers and health center programs, and if meaningful results are achieved, expect nationwide expansion to other regions.
        - Public prevention model: Spread as a family-participatory preventive health model.

2. Business Model
    - **Customers (Who)**
        - Individuals and families: Parents requiring care due to chronic illness, accidents, aging, or who are active in their own health management, and children who want to periodically check and communicate about parents' health
        - Companies and insurance companies: Organizations needing employee welfare, customer management, medical cost reduction
        - Local governments: Public institutions seeking to expand health, prevention, and care-related projects like elderly care programs
    - **Revenue Structure**
        - Subscription model: Premium subscription-based in-app purchase structure providing features and benefits not available in the free version for **2,900 won/month**.
        - Partnerships and advertising: Collaborate with health foods, health checkups, exercise YouTube channels, etc. to sell affiliated products and content for commission.
        - B2B, B2B2C contracts: Enable companies, insurance companies, local governments to provide OnGi services to employees and subscribers, receiving usage fees.
        - Wearable bundle: Bundle sales with wearable devices, allowing bundle purchasers to freely experience paid-only benefits for 1 year. Share referral fees and joint marketing costs with device sales organizations.
    - **Cost Structure**
        - Fixed costs: Server, security, app development and design, customer support, certification management, etc.
        - Variable costs: Notification and storage costs, affiliate reward settlement, payment fees, etc.
    - **Risk Management**
        - Personal information protection: Provide more thorough personal information management through encryption, access restrictions, consent and withdrawal functions for safe user use.
        - Medical device regulation response: Provide certified operation within the scope of health management services.
        - Reward fairness: Transparently disclose 'Temperature Index' increase/decrease rules, reward exchange conditions, and usage records to the family on the my page.

## 8. Team Introduction

| Yang Junyoung | Kim Yunyoung | Park Minji | Ok Somi | Lee Taekyung | Choi Hyuna |
|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|
|<img width="100px" alt="Yang Junyoung" src="https://github.com/pnuswedu/SW-Hackathon-2024/assets/34933690/f5b5df2a-e174-437d-86b2-a5a23d9ee75d" /> | <img width="100px" alt="Kim Yunyoung" src="https://avatars.githubusercontent.com/u/143103801?v=4" /> | <img width="100px" alt="Park Minji" src="https://github.com/pnuswedu/SW-Hackathon-2024/assets/34933690/fe4e8910-4565-4f3f-9bd1-f135e74cb39d" /> | <img width="100px" alt="Ok Somi" src="https://avatars.githubusercontent.com/u/141479699?v=4" /> | <img width="100px" alt="Lee Taekyung" src="https://avatars.githubusercontent.com/u/171523747?v=4" /> | <img width="100px" alt="Choi Hyuna" src="https://github.com/pnuswedu/SW-Hackathon-2024/assets/34933690/675d8471-19b9-4abc-bf8a-be426989b318" /> |
| Dept. of Computer Science and Engineering | Dept. of Computer Science and Engineering <br/> Computer Engineering Major | Dept. of Media & Communication | Dept. of Computer Science and Engineering <br/> Computer Engineering Major | Dept. of Computer Science and Engineering <br/> AI Major | Dept. of Design <br/> Visual Design Major |
| y.jun0@pusan.ac.kr | dbsdud3272@pusan.ac.kr | 0810minji@naver.com | osm0071@naver.com | taekoong@pusan.ac.kr | hyun_a_923@naver.com |
| Team Lead <br/> Backend Development | Frontend Development | Planning & Presentation | Backend Development | Frontend Development | Design |

<br/>

## 9. Hackathon Participation Review

- **Yang Junyoung**:
  At first, I was worried about whether I could complete the long project spanning about 4 months from May to September, but I'm proud to have finished it successfully. Above all, the fact that I could learn and gain a lot through this hackathon by collaborating in a different way than before was very meaningful. I usually only did projects within the same department, but this hackathon was the first time I could collaborate with people from different departments and various fields. Having people with different backgrounds together broadened our perspective on problems, and I feel the project's completeness improved significantly because of it.

- **Kim Yunyoung**:
  This hackathon gave me many firsts. It was my first time participating in a long-term hackathon, my first time implementing everything from file structure to completion myself, and my first time working together with various job functions to achieve a goal. Because everything was new, there were many difficulties, but only now at the end of our hard work do I realize that all those difficulties were stepping stones to achieve our goal.

- **Park Minji**:
  The hackathon was difficult in that we had to come up with ideas and realize them in a short period, but it was also a great experience where we could achieve great results in a short time. Going through many meetings and feedback was a big learning experience, and the service development process that I thought I would never do in my life was an amazing experience.

- **Ok Somi**:
  This hackathon was my first experience participating in a long-term hackathon. Unlike short-term hackathons, I liked that we could think and adjust the process from planning to development sufficiently. At first, collaborating with people from various departments and job functions was unfamiliar, but through the process of respecting each other's strengths and ideas and growing as one team, I could learn and grow a lot.

- **Lee Taekyung**:
  Through this hackathon, I could feel how wonderful it is for various job functions to come together and work hard to complete one service. There were difficulties in creating the service, but the results created through team members thinking together and finding solutions were very meaningful.

- **Choi Hyuna**:
  Since I've always done projects within the same job function, I had a thirst for collaborating with people of various majors. The hackathon was a meaningful opportunity to quench this thirst and collaborate with other job functions like development and planning.

## 10. References

Choi Yoonju (2022, 7, 22). 9 out of 10 Koreans are very interested in active health management. <Dental Arirang>. Retrieved
from [https://www.dentalarirang.com/news/articleView.html?idxno=35683](https://www.dentalarirang.com/news/articleView.html?idxno=35683)
