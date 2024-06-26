import React, { useContext, useState } from 'react';
import { UserContext } from '../context/UserContext';
import { AnimatedPage } from './AnimatedPage';
import { ErrorMsg } from './ErrorMsgPage';
import { Link, useNavigate } from 'react-router-dom';
import '../index.css'

export const TeacherLoginPage = ()=>{
    const [temail,settemail] = useState("")
    const navigate = useNavigate()
    const [tpassword,settpassword] = useState("")
    const [errorMsg, seterrorMsg] = useState("")
    const [ttoken,setttoken] =  useContext(UserContext)

    const submittLogin = async()=>{
        const requestOptions = {
            method:"POST",
            headers:{"Content-Type":"application/x-www-form-urlencoded"},
            body:JSON.stringify(`grant_type=&username=${temail}&password=${tpassword}&scope=&client_id=&client_secret=`)   
        }
        const url = `${process.env.REACT_APP_STUDENT_URL}/token`
        const response = await fetch(url, requestOptions)
        const data = await response.json()

        if(!response.ok){
            console.log(data)
            seterrorMsg(data.detail)

        }
        else{
            setttoken(data.access_token)
            console.log(ttoken)
            localStorage.setItem("teacherToken", data.access_token);
            navigate("/tdashboard")
        }

    }
    const handletSubmit = (e)=>{
        e.preventDefault();
        submittLogin();
    }
    return(
        <AnimatedPage>
        <>

            <section className="sec1">
                <main className='lgmaindiv'>
                <div className='bgimagediv'>
                    <img id='stlbgimage' className='stlbgimage' src='assets/images/stlbgimg.png' alt='stlbgimage'/>
                </div>
                    <div className="container">
                        <div className="row">

                            <div className="col-2">
                                <div className="contacticons">
                                    <div className="mail">
                                        <img className="" style={{width:"43px"}} src="assets/images/icons8-gmail-logo-64.png" alt="" />
                                    </div>
                                    <div className="skype">
                                        <img style={{width:"43px"}} src="assets/images/icons8-skype-2019-64.png" alt="" />
                                    </div>
                                    <div className="discord">
                                        <img style={{width:"43px"}} src="assets/images/icons8-discord-64.png" alt="" />
                                    </div>
                                </div>
                            </div>

                            <div className="col-6 my-4">
                                <div className="mainimg">
                                    <img className='character1' src="assets/images/character.png" alt="chacter" />
                                </div>
                            </div>

                            <div className="col-4 my-5">
                                <div className="loginform my-5" style={{width:"300px"}}>

                                    <form  id="lgform"  onSubmit={handletSubmit} className="" action="" method="">
                                        <div className="form-floating mb-4 email">
                                            <input style={{height:"50px"}} type="email" value={temail} onChange={(e)=>{settemail(e.target.value)}} className="em form-control" id="floatingInput" placeholder="name@example.com" />
                                            <label htmlFor="floatingInput">Email address</label>
                                        </div>
                                        <div className="form-floating">
                                            <input style={{height:"50px"}} value={tpassword} onChange={(e)=>{settpassword(e.target.value)}} type="password" className="em password form-control" id="floatingPassword" placeholder="Password" />
                                            <label htmlFor="floatingPassword">Password</label>
                                        </div>
                                    
                
                                    <div className="line2">
                                        <ErrorMsg message={errorMsg}/>
                                    </div>
                                    <div className="line3 my-3">
                                        <button type="submit" className="sgbtn btn btn-primary w-100 shadow">SIGN IN</button>
                                    </div>
                                    <div>
                                        <Link className="recpass text-primary" id="registerbtn" to="/register"><span className="text-dark me-2">don't have an account yet?</span>Register</Link>
                                    </div>
                                    </form>

                                </div>

                            </div>
                        </div>
                    </div>
                </main>
            </section>

        </>
        </AnimatedPage>
    )
}