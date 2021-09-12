local QuizScript = {}

QuizScript.Properties = {
	{name = "quizName", type = "string"},
}

function QuizScript:OnInteract(player)
	player:SendToLocal("QuizLocal", self.properties.quizName, self:GetEntity(), "QuizEndLocal")
end

function QuizScript:OnTriggerEnter(player)
	self:OnInteract(player)
end

function QuizScript:QuizEndLocal()
	-- Hide this quiz element for the current player only after the quiz is completed
	self:GetEntity():GetParent().visible = false
	self:GetEntity().interactable = false
end

function QuizScript:DefineQuizzes()
	local quizzes = {
		mushroom0 = {
			question = [[Your web application needs to be accessed by employees, partners and contractors 
			worldwide. You also want to restrict access based on the type of client device, time of day 
			and country of request origin. What GCP service would you use?]],
			answer1 = "Cloud Armor",
			answer2 = "Global Load Balancer",
			answer3 = "Identity Aware Proxy",
			answer4 = "Traffic Director",
			answer5 = "Security Control Center",
			correctAnswer = 3, -- Right answer to the question
		},
		mushroom1 = {
			question = [[You are writing an app that will run in GKE. Your app needs to connect to 
			GCP Pub/Sub, GCS and CloudSQL. How would you configure security for your GKE cluster? ]],
			answer1 = "Create GCP Service Accounts and use Workload Identity for GKE",
			answer2 = "Create secret keys and store them in KMS. My app will use k8s secrets to access KMS",
			answer3 = "Store secret keys in a saparate Git Repo and merge it with my app in CICD",
			answer4 = "Dynamically inject secrets into GKE app by using environment variables",
			answer5 = "Create k8s Service Accounts and RBAC for GKE cluster",
			correctAnswer = 1, -- Right answer to the question
		},
		mushroom2 = {
			question = [[What is the role of the kubelet in a Kubernetes cluster?]],
			answer1 = "Stores k8s configuration information",
			answer2 = "A smaller version of Kubernetes",
			answer3 = "A device that collects data in an organized manner for easy access",
			answer4 = "A node agent that manages pods and their containers",
			answer5 = "Software that is used to run containers outside of pods",
			correctAnswer = 4, -- Right answer to the question
		},
		mushroom3 = {
			question = [[You are building a microservices Java app to run on GKE. 
			One of the security requirements is to encrypt all inter-service traffic with mTLS. 
			What is the fastest way to implement this requirement?]],
			answer1 = "Traffic Director",
			answer2 = "Istio Service Mesh",
			answer3 = "GKE Ingress",
			answer4 = "Internal Load Balancer",
			answer5 = "Java mTLS library",
			correctAnswer = 2, -- Right answer to the question
		},
		mushroom4 = {
			question = [[You are writing a SaaS app that runs microservices in containers managed 
			by Kubernetes. Your customers need the ability to run their workloads on GCP, AWS, or Azure.
			You, being PaaS provider need to have single pane of glass view into all clusters and resources.
			Which one of these can help you achive this?]],
			answer1 = "Google Anthos",
			answer2 = "Google App Engine",
			answer3 = "Google Deployment Manager",
			answer4 = "Google Kubernetes Engine",
			answer5 = "None of the above",
			correctAnswer = 1, -- Right answer to the question
		},
		mushroom5 = {
			question = [[Your organization runs container based apps on a shared Kubernetes cluster. 
						One of the security requirements is to provide workload isolation and grant permissions to 
						DevOps staff in different lines of businesses only to their own applications.
						Which of these Kubernetes features would allow you to meet this requirement?]],
			answer1 = "Containers",
			answer2 = "Pods",
			answer3 = "Etcd",
			answer4 = "Kube proxy",
			answer5 = "Namespaces",
			correctAnswer = 5, -- Right answer to the question
		},
		mushroom6 = {
			question = [[You are building video streaming service and need to store large video files and be 
						able to stream video to end users. Which of these GCP services would you use?]],
			answer1 = "Cloud Storage and CDN",
			answer2 = "Global Load Balancer and Compute Engine",
			answer3 = "App Engine and Firestore",
			answer4 = "GKE and Firestore",
			answer5 = "CloudSQL and SDN",
			correctAnswer = 1, -- Right answer to the question
		},
		mushroom7 = {
			question = [[What component of Kubernetes is responsible for storing cluster state 
					and related metadata?]],
			answer1 = "Kube scheduler",
			answer2 = "Kube proxy",
			answer3 = "API server",
			answer4 = "Kubelet",
			answer5 = "Etcd",
			correctAnswer = 5, -- Right answer to the question
		},
		mushroom8 = {
			question = [[Your app runs in Kubernetes cluster and some of the services require GPUs. 
				Not all of the worker nodes in a cluster have GPUs. What Kubernetes feature can help you make 
				sure that those deployments that need GPU run on proper nodes in a simplest way?]],
			answer1 = "Namespace quota",
			answer2 = "PodSpec nodeSelector",
			answer3 = "Node taints and PodSpec tolerations",
			answer4 = "PodSpec affinity/anti-affinity",
			answer5 = "None of the above",
			correctAnswer = 2, -- Right answer to the question
		},
		mushroom9 = {
			question = [[One of the security requirements for your GKE deployment is to only 
						allow deployment of trusted container images that undergone proper 
						verification as part of your CICD pipeline. 
						What GCP capability would you use to implement it?]],
			answer1 = "Security Command Center",
			answer2 = "IAM",
			answer3 = "Cloud Build",
			answer4 = "Binary Authorization",
			answer5 = "Container Vulnerability Scanning",
			correctAnswer = 4, -- Right answer to the question
		},
		mushroom10 = {
			question = [[You run multiple Kubernetes clusters and need to make sure all of them 
					comply with consistent security policy, resource contraints, logging, auditing, etc.
					What component of GCP can help you implement this?]],
			answer1 = "Anthos Config Management",
			answer2 = "Security Command Center",
			answer3 = "Intelligent Assistant",
			answer4 = "Cloud Functions",
			answer5 = "Config Connector",
			correctAnswer = 1, -- Right answer to the question
		},
		mushroom11 = {
			question = [[You have built a new version of the application container image 
						and need to redeploy it into your Kubernetes cluster without a downtime. 
						What command would you use?]],
			answer1 = "kubectl update -f app.yaml",
			answer2 = "kubectl set image deployment/frontend www=image:v2",
			answer3 = "kubectl rollout restart deployment/frontend",
			answer4 = "kubectl replace --force -f app.yaml",
			answer5 = "kubectl patch pod frontend",
			correctAnswer = 2, -- Right answer to the question
		},
		mushroom12 = {
			question = [[You are building container based application that will run on Kubernetes.
						One of the microservices in the application needs to respond to HTTP requests
						with unpredictable traffic patterns scaling from the minimum of 100 requests 
						per second to 50,000 requests per second. This microservice needs to access an 
						existing database and itself is stateless. How would you deploy this service 
						into your GKE cluster?]],
			answer1 = "DaemonSet",
			answer2 = "StatefulSet",
			answer3 = "Job",
			answer4 = "Scheduler",
			answer5 = "Deployment",
			correctAnswer = 5, -- Right answer to the question
		},
		mushroom13 = {
			question = [[Your simple application runs on Kubernetes cluster as five different Deployments. 
						What Kubernetes construct would you use to allow these services to connect 
						to each other?]],
			answer1 = "Network policy",
			answer2 = "Service Mesh",
			answer3 = "Load balancer",
			answer4 = "Ingress",
			answer5 = "Service",
			correctAnswer = 5, -- Right answer to the question
		},
		coconut11 = {
			question = "What is the best place to store service secrets for GKE applcations?",
			answer1 = "File system mounted via persistent volume claim",
			answer2 = "Secure Git repository",
			answer3 = "Encrypted Object Storage object",
			answer4 = "Inside of the container image",
			answer5 = "Key Management Service",
			correctAnswer = 5, -- Right answer to the question
		},
		coconut12 = {
			question = [[You want to control traffic flow at the IP address or port level between 
						pods deployed in your Kubernetes cluster. What mechanism would you use?]],
			answer1 = "Pod security policy",
			answer2 = "Service mesh",
			answer3 = "Network policy",
			answer4 = "Resource quota",
			answer5 = "IP tables",
			correctAnswer = 3, -- Right answer to the question
		},
		coconut13 = {
			question = "What are good reasons to serve mixed HTTP and HTTPS traffic on your website?",
			answer1 = "Conserve compute resources by not doing encryption",
			answer2 = "Reduce latency by avoiding delays of encryption",
			answer3 = "Simplify server configuration",
			answer4 = "Allow for larger variety of clients to connect to the application",
			answer5 = "None of the above",
			correctAnswer = 5, -- Right answer to the question
		},
		coconut14 = {
			question = [[Which of these represents a valid list of Kubernetes control plane components? 
						(excluding node components)]],
			answer1 = "kube apiserver, etcd, kube scheduler, kube controller manager, node controller, replication controller, endpoints controller, service account & token controllers, cloud controller manager, kubelet, kube proxy",
			answer2 = "kubelet, kube proxy, container runtime",
			answer3 = "kube apiserver, kube scheduler, replication controller, endpoints controller, service account & token controllers, cloud controller manager",
			answer4 = "kube apiserver, etcd, kube scheduler, kube controller manager, node controller, replication controller, endpoints controller, service account & token controllers, cloud controller manager",
			answer5 = "kube controller manager, node controller, replication controller, endpoints controller, service account & token controllers, cloud controller manager",
			correctAnswer = 4, -- Right answer to the question
		},
		coconut15 = {
			question = [[You need to run your GKE cluster so that a zonal outage does not cause application 
						nor control plane downtime. Which type of GKE cluster would you use?]],
			answer1 = "Zonal cluster",
			answer2 = "Regional cluster",
			answer3 = "Multi-regional cluster",
			answer4 = "Multi-zonal cluster",
			answer5 = "Any of the above",
			correctAnswer = 2, -- Right answer to the question
		},
		coconut16 = {
			question = [[You run stateless application as a Deployment on GKE and need the ability to scale 
					the processing capacity depending on the volume of user traffic. Which of the following scaling 
					methods would you use?]],
			answer1 = "Vertical pod autoscaling",
			answer2 = "Horizontal pod autoscaling",
			answer3 = "Node pools",
			answer4 = "Manually scale the application",
			answer5 = "Cluster autoscaler",
			correctAnswer = 2, -- Right answer to the question
		},
		coconut17 = {
			question = [[You are building a stateless RESTful stock quote service that is called by 
						clients from the internet and uses backend Cloud Memorystore as a source of data. 
						The application is written in C++. What would be your first choice of deployment form 
						factor on GCP to minimize the management overhead and cost?]],
			answer1 = "App Engine",
			answer2 = "Cloud Functions",
			answer3 = "Compute Engine",
			answer4 = "Cloud Run for Anthos",
			answer5 = "Cloud Run Managed",
			correctAnswer = 5, -- Right answer to the question
		},
		coconut18 = {
			question = [[What is the recommended and default container runtime environment in GKE?]],
			answer1 = "Docker",
			answer2 = "Containerd",
			answer3 = "CRI-O",
			answer4 = "runC",
			answer5 = "None of the above",
			correctAnswer = 2, -- Right answer to the question
		},
		coconut19 = {
			question = [[What is the benefit of using gVisor?]],
			answer1 = "Better container isolation",
			answer2 = "Improved resource utilization",
			answer3 = "Ability to control network security",
			answer4 = "Improved auditing and logging",
			answer5 = "Automatic scanning for container vulnerabilities",
			correctAnswer = 1, -- Right answer to the question
		},
		coconut20 = {
			question = [[What company has originally developer of Kubernetes and donated it to Open Source?]],
			answer1 = "IBM",
			answer2 = "Google",
			answer3 = "Microsoft",
			answer4 = "Amazon",
			answer5 = "Apache Software Foundation",
			correctAnswer = 2, -- Right answer to the question
		},
		coconut21 = {
			question = [[What are examples of a fully managed and serverless services on GCP?]],
			answer1 = "Compute Engine, App Engine, GKE, Anthos, PubSub, Cloud Storage, Firestore, AutoML",
			answer2 = "Cloud Functions, Big Table, Cloud SQL, GKE, IAP, CDN",
			answer3 = "Persistent Disk, Cloud Storage, CDN, Memorystore, Cloud Console",
			answer4 = "Cloud Run Managed, BigQuery, Cloud Functions, Firestore, Cloud Storage, PubSub",
			answer5 = "App Engine, GKE, GCE, CloudSQL, Spanner, Cloud Monitoring, Cloud Logging",
			correctAnswer = 4,
		},
		coconut22 = {
			question = [[With uptime SLA of 99.99%, what is expected downtime per year?]],
			answer1 = "< 8 hours 45 min",
			answer2 = "< 53 min",
			answer3 = "between 5 to 53 min",
			answer4 = "< 5 minutes",
			answer5 = "> 5 minutes",
			correctAnswer = 2,
		},
		coconut23 = {
			question = [[What is the approximate roundtrip of a network packet between GCP regions on US West Coast to US East Coast?]],
			answer1 = "~640 ms",
			answer2 = "~320 ms",
			answer3 = "~160 ms",
			answer4 = "~80 ms",
			answer5 = "~40 ms",
			correctAnswer = 5,
		},
		coconut24 = {
			question = [[What is the Google Cloud recommended best practice for centralized network control across projects?]],
			answer1 = "VPN",
			answer2 = "VPC Peering",
			answer3 = "VPC",
			answer4 = "Shared VPC",
			answer5 = "Subnet",
			correctAnswer = 4,
		},
		coconut25 = {
			question = [[What is VPC Peering?]],
			answer1 = "Connects Google Cloud VPC networks to on-premises networks",
			answer2 = "Connects VPC networks so that workloads in different VPC networks can communicate without using public IPs",
			answer3 = "Connects different networks in different projects over a VPN",
			answer4 = "Connects VPC networks so that workloads in the same project can communicate internally",
			answer5 = "Connects Google Cloud VPC networks to other public clouds networks",
			correctAnswer = 2,
		},
		coconut26 = {
			question = [[In the default network, what is the behavior of the pre-populated firewall rules?]],
			answer1 = "Allows ingress connections for all protocols and ports among instances in the network",
			answer2 = "Allows ingress connections for SSH, RDP and ICMP protocols only among instances in the network",
			answer3 = "Denies all traffic on the network",
			answer4 = "Allows only connections from authorized VPN tunnels",
			answer5 = "Allows egress connections for SSH, RDP and ICMP protocols only among instances in the network",
			correctAnswer = 1,
		},
		coconut27 = {
			question = [[What are the implied firewalls in every VPC network that can be overridden but cannot be removed?]],
			answer1 = "Implied allow ingress and deny egress rules",
			answer2 = "Implied allow all traffic on the internal Google Cloud network",
			answer3 = "Implied allow all traffic on the customers VPC Peered networks",
			answer4 = "Implied deny all traffic from other public clouds",
			answer5 = "Implied allow egress and deny ingress rules",
			correctAnswer = 5,
		},
		-- ----------------------------------------- all quizzes below have not yet been assigned
		coconut28 = {
			question = [[?]],
			answer1 = "",
			answer2 = "",
			answer3 = "",
			answer4 = "",
			answer5 = "",
			correctAnswer = 5,
		},
		coconut29 = {
			question = [[?]],
			answer1 = "",
			answer2 = "",
			answer3 = "",
			answer4 = "",
			answer5 = "",
			correctAnswer = 5,
		},
		coconut30 = {
			question = [[?]],
			answer1 = "",
			answer2 = "",
			answer3 = "",
			answer4 = "",
			answer5 = "",
			correctAnswer = 5,
		},
		coconut31 = {
			question = [[?]],
			answer1 = "",
			answer2 = "",
			answer3 = "",
			answer4 = "",
			answer5 = "",
			correctAnswer = 5,
		},
		coconut32 = {
			question = [[?]],
			answer1 = "",
			answer2 = "",
			answer3 = "",
			answer4 = "",
			answer5 = "",
			correctAnswer = 5,
		},
		coconut33 = {
			question = [[?]],
			answer1 = "",
			answer2 = "",
			answer3 = "",
			answer4 = "",
			answer5 = "",
			correctAnswer = 5,
		},
		coconut34 = {
			question = [[?]],
			answer1 = "",
			answer2 = "",
			answer3 = "",
			answer4 = "",
			answer5 = "",
			correctAnswer = 5,
		},
		coconut35 = {
			question = [[?]],
			answer1 = "",
			answer2 = "",
			answer3 = "",
			answer4 = "",
			answer5 = "",
			correctAnswer = 5,
		},
		coconut36 = {
			question = [[?]],
			answer1 = "",
			answer2 = "",
			answer3 = "",
			answer4 = "",
			answer5 = "",
			correctAnswer = 5,
		},
		coconut37 = {
			question = [[?]],
			answer1 = "",
			answer2 = "",
			answer3 = "",
			answer4 = "",
			answer5 = "",
			correctAnswer = 5,
		},
		coconut38 = {
			question = [[?]],
			answer1 = "",
			answer2 = "",
			answer3 = "",
			answer4 = "",
			answer5 = "",
			correctAnswer = 5,
		},
--[[
How can VMs without external IPs and private GKE clusters talk to services on the public internet?	Using NAT
You need to deploy a web application into GKE. You expect moderate workload that will fluctuate over time in volume. One of the main criteria is cost efficiency. What CPU type will you use for your GKE Nodes and why?	E2 because it offers lowest cost and does not need to run non-stop in order to get benefits from SUDs
What feature of Anthos allows administrators to enforce the proper software supply chain security?	Binary Authorization
Which Anthos feature allows you to create a common configuration across all your Kubernetes clusters whether on-premises or in the cloud.	Anthos Config Management
How can you get up to 57% off the cost of a vm running on GCP?	Committed use discount(s)
What GKE feature automatically resizes the number of nodes in a given node pool, based on the demands your workloads?	Cluster autoscaler
What is the Google Kubernetes Engine (GKE) addon allows you to manage your Google Cloud infrastructure the same way you manage your Kubernetes applications?	Config Connector
What can you integrate with the HTTP(S) load balancer to provide DDoS protection and the ability to whitelist and blacklist IP addresses at the edge?	Google Cloud Armor
Which Google Cloud service enables "zero trust access" - an enterprise security model that enables employees to work from untrusted networks without the use of a VPN.	Identity Aware Proxy

Your organization develops and tests multiple applications on Compute Engine virtual machine instances across 3 environments; Test, Staging, and Production. The separate development teams for each application require minimal access to Production but broad access in Test and Staging. You need to design the Resource Manager structure to support your organization in following least-privilege best practices. What should you do?
A. Create one project per environment. Assign the application team members an Identity Access Management (IAM) role at the project level.
B. Create one project per environment. Group each application team member into a Google Group. Assign the application team’s Google Group an IAM role at the project level.
C. Create one project per environment per application. Assign the application team members an IAM role at the project level.
D. Create one project per environment per application. Group each application team member into a Google Group. Assign the application team’s Google Group an IAM role at the project level.

Your application that is deployed in the App Engine standard environment receives a large amount of traffic. You are concerned that deploying changes to the application could affect all users negatively. You want to avoid full-scale load testing due to cost concerns, but you still want to deploy new features as quickly as possible. Which approach should you take?
A. Schedule weekly load tests against the production application.
B. Use the local development environment to perform load testing outside Google Cloud.
C. Before allowing users to access new features, deploy as a new version and perform smoke tests. Then enable all users to access the new features.
D. Use App Engine traffic splitting to have a smaller part of the users test out new features, and slowly adjust traffic splitting until all users get the new features.

Your website is deployed on Compute Engine. Your marketing team wants to test conversion rates between 3 different website designs. You are not able to make changes to your application code. What should you do?
A. Deploy website on App Engine and use traffic splitting.
B. Deploy website on App Engine as three separate services.
C. Deploy website on Cloud Functions and implement custom code to show different designs.
D. Deploy website on Cloud Functions as three separate functions.

You have an application that accepts inputs from users. The application needs to kick off different background tasks based on these inputs. You want to allow for automated asynchronous execution of these tasks as soon as input is submitted by the user. Which product should you use?
A. Cloud Tasks
B. Cloud Bigtable
C. Cloud Pub/Sub
D. Cloud Composer

As your organization has grown, new teams need access to manage network connectivity within and across projects. You are now seeing intermittent timeout errors in your application. You want to find the cause of the problem. What should you do?
A. Set up wireshark on each Google Cloud Virtual Machine instance.
B. Review the instance admin activity logs in Cloud Logging for the application instances.
C. Configure VPC flow logs for each of the subnets in your VPC.
D. Configure firewall rules logging for each of the firewalls in your VPC.

You are capturing important audit activity in Cloud Logging. You need to read the information from Cloud Logging to perform real-time analysis of the logs. You will have multiple processes performing different types of analysis on the logging data. What should you do?
A. Read the logs directly from the Cloud Logging API.
B. Set up a Cloud Logging sync to BigQuery, and read the logs from the BigQuery table.
C. Set up a Cloud Logging sync to Cloud Pub/Sub, and read the logs from a Cloud Pub/Sub topic.
D. Set up a Cloud Logging sync to Cloud Storage, and read the logs from a Cloud Storage bucket.

You are writing an API endpoint to process orders from a web application and save the data into a Datastore collection. During application testing, you notice that when your application encounters an HTTP 5xx server error from the Datastore API, it catches this error and returns an HTTP 200 OK response code to the client, but does not store the data within Datastore. You want the consumers of your API endpoint to know that the write request was unsuccessful. What should you do?
A. Return an HTTP 204 No Content response.
B. Return an HTTP 406 Not Acceptable response.
C. Return an HTTP 500 Internal Server Error response.
D. Retry the Datastore API with exponential backoff until Datastore returns a HTTP 2xx response.

Your company wants to deploy several microservices to help their system handle elastic loads. Each microservice uses a different version of software libraries. You want to enable their developers to keep their development environment in sync with the various production services. Which technology should you choose?
A. RPM/DEB
B. Containers
C. Chef/Puppet
D. Virtual machines

You are designing a large distributed application with 30 microservices. Each of your distributed microservices needs to connect to a database backend. You want to store the credentials securely. Where should you store the credentials?
A. In the source code
B. In an environment variable
C. In a key management system
D. In a config file that has restricted access through ACLs

Mountkirk Games wants to set up a continuous delivery pipeline. Their architecture includes many small services that they want to be able to update and roll back quickly. Mountkirk Games has the following requirements: (1) Services are deployed redundantly across multiple regions in the US and Europe, (2) Only frontend services are exposed on the public internet, (3) They can reserve a single frontend IP for their fleet of services, and (4) Deployment artifacts are immutable. Which set of products should they use?
A. Cloud Storage, Cloud Dataflow, Compute Engine
B. Cloud Storage, App Engine, Cloud Load Balancing
C. Container Registry, Google Kubernetes Engine, Cloud Load Balancing
D. Cloud Functions, Cloud Pub/Sub, Cloud Deployment Manager

Your customer is moving their corporate applications to Google Cloud. The security team wants detailed visibility of all resources in the organization. You use Resource Manager to set yourself up as the Organization Administrator. Which Cloud Identity and Access Management (Cloud IAM) roles should you give to the security team while following Google recommended practices?
A. Organization viewer, Project owner
B. Organization viewer, Project viewer
C. Organization administrator, Project browser
D. Project owner, Network administrator

You are a project owner and need your co-worker to deploy a new version of your application to App Engine. You want to follow Google’s recommended practices. Which IAM roles should you grant your co-worker?
A. Project Editor
B. App Engine Service Admin
C. App Engine Deployer
D. App Engine Code Viewer

Your company has reserved a monthly budget for your project. You want to be informed automatically of your project spend so that you can take action when you approach the limit. What should you do?
A. Link a credit card with a monthly limit equal to your budget.
B. Create a budget alert for 50%, 90%, and 100% of your total monthly budget.
C. In App Engine Settings, set a daily budget at the rate of 1/30 of your monthly budget.
D. In the GCP Console, configure billing export to BigQuery. Create a saved view that queries your total spend.

You developed a new application for App Engine and are ready to deploy it to production. You need to estimate the costs of running your application on Google Cloud Platform as accurately as possible. What should you do?
A. Create a YAML file with the expected usage. Pass this file to the "gcloud app estimate" command to get an accurate estimation.
B. Multiply the costs of your application when it was in development by the number of expected users to get an accurate estimation.
C. Use the pricing calculator for App Engine to get an accurate estimation of the expected charges.
D. Create a ticket with Google Cloud Billing Support to get an accurate estimation.

Your company processes high volumes of IoT data that are time-stamped. The total data volume can be several petabytes. The data needs to be written and changed at a high speed. You want to use the most performant storage option for your data. Which product should you use?
A. Cloud Datastore
B. Cloud Storage
C. Cloud Bigtable
D. BigQuery

Your application has a large international audience and runs stateless virtual machines within a managed instance group across multiple locations. One feature of the application lets users upload files and share them with other users. Files must be available for 30 days; after that, they are removed from the system entirely. Which storage solution should you choose?
A. A Cloud Datastore database.
B. A multi-regional Cloud Storage bucket.
C. Persistent SSD on virtual machine instances.
D. A managed instance group of Filestore servers.

You need to create a new Kubernetes Cluster on Google Cloud Platform that can autoscale the number of worker nodes. What should you do?
A. Create a cluster on Kubernetes Engine and enable autoscaling on Kubernetes Engine.
B. Create a cluster on Kubernetes Engine and enable autoscaling on the instance group of the cluster.
C. Configure a Compute Engine instance as a worker and add it to an unmanaged instance group. Add a load balancer to the instance group and rely on the load balancer to create additional Compute Engine instances when needed.
D. Create Compute Engine instances for the workers and the master, and install Kubernetes. Rely on Kubernetes to create additional Compute Engine instances when needed.

Your company has a mission-critical application that serves users globally. You need to select a transactional, relational data storage system for this application. Which two products should you choose?
A. BigQuery
B. Cloud SQL
C. Cloud Spanner
D. Cloud Bigtable
E. Cloud Datastore

You have a Kubernetes cluster with 1 node-pool. The cluster receives a lot of traffic and needs to grow. You decide to add a node. What should you do?
A. Use "gcloud container clusters resize" with the desired number of nodes.
B. Use "kubectl container clusters resize" with the desired number of nodes.
C. Edit the managed instance group of the cluster and increase the number of VMs by 1.
D. Edit the managed instance group of the cluster and enable autoscaling.

You have created a Kubernetes deployment, called Deployment-A, with 3 replicas on your cluster. Another deployment, called Deployment-B, needs access to Deployment-A. You cannot expose Deployment-A outside of the cluster. What should you do?
A. Create a Service of type NodePort for Deployment A and an Ingress Resource for that Service. Have Deployment B use the Ingress IP address.
B. Create a Service of type LoadBalancer for Deployment A. Have Deployment B use the Service IP address.
C. Create a Service of type LoadBalancer for Deployment A and an Ingress Resource for that Service. Have Deployment B use the Ingress IP address.
D. Create a Service of type ClusterIP for Deployment A. Have Deployment B use the Service IP address.

You want to find out who in your organization has Owner access to a project called "my-project".What should you do?
A. In the Google Cloud Platform Console, go to the IAM page for your organization and apply the filter "Role:Owner".
B. In the Google Cloud Platform Console, go to the IAM page for your project and apply the filter "Role:Owner".
C. Use "gcloud iam list-grantable-role --project my-project" from your Terminal.
D. Use "gcloud iam list-grantable-role" from Cloud Shell on the project page.

You want to create a new role for your colleagues that will apply to all current and future projects created in your organization. The role should have the permissions of the BigQuery Job User and Cloud Bigtable User roles. You want to follow Google’s recommended practices. How should you create the new role?
A. Use "gcloud iam combine-roles --global" to combine the 2 roles into a new custom role.
B. For one of your projects, in the Google Cloud Platform Console under Roles, select both roles and combine them into a new custom role. Use "gcloud iam promote-role" to promote the role from a project role to an organization role.
C. For all projects, in the Google Cloud Platform Console under Roles, select both roles and combine them into a new custom role.
D. For your organization, in the Google Cloud Platform Console under Roles, select both roles and combine them into a new custom role.

You work in a small company where everyone should be able to view all resources of a specific project. You want to grant them access following Google’s recommended practices. What should you do?
A. Create a script that uses "gcloud projects add-iam-policy-binding" for all users’ email addresses and the Project Viewer role.
B. A. Create a script that uses "gcloud iam roles create" for all users’ email addresses and the Project Viewer role.
C. Create a new Google Group and add all users to the group. Use "gcloud projects add-iam-policy-binding" with the Project Viewer role and Group email address.
D. Create a new Google Group and add all members to the group. Use "gcloud iam roles create" with the Project Viewer role and Group email address.

You need to verify the assigned permissions in a custom IAM role. What should you do?
A. Use the GCP Console, IAM section to view the information.
B. Use the "gcloud init" command to view the information.
C. Use the GCP Console, Security section to view the information.
D. Use the GCP Console, API section to view the information.

============ Left to copy
https://cloud.google.com/certification/cloud-devops-engineer
https://cloud.google.com/certification/cloud-security-engineer
https://cloud.google.com/certification/cloud-network-engineer
]]		
	}
	
	-- Calculate max possible score
	local totalPoints = 0
	local size = 0
	for _,value in pairs(quizzes) do
		value.points = 5
		value.errors = 0
		value.passed = false
		totalPoints = totalPoints + value.points
		size = size + 1
	end
	
	quizzes["totalPoints"] = totalPoints
	quizzes["size"] = size
	
	return quizzes
end

return QuizScript